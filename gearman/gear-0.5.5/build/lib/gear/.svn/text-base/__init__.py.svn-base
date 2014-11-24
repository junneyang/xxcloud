# Copyright 2013-2014 OpenStack Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

import errno
import logging
import os
import select
import socket
import ssl
import struct
import threading
import time
import uuid as uuid_module

from gear import constants
from gear.acl import ACLError, ACLEntry, ACL  # noqa

try:
    import Queue as queue
except ImportError:
    import queue as queue

try:
    import statsd
except ImportError:
    statsd = None

PRECEDENCE_NORMAL = 0
PRECEDENCE_LOW = 1
PRECEDENCE_HIGH = 2


class ConnectionError(Exception):
    pass


class InvalidDataError(Exception):
    pass


class ConfigurationError(Exception):
    pass


class NoConnectedServersError(Exception):
    pass


class UnknownJobError(Exception):
    pass


class InterruptedError(Exception):
    pass


class TimeoutError(Exception):
    pass


class GearmanError(Exception):
    pass


def convert_to_bytes(data):
    try:
        data = data.encode('utf8')
    except AttributeError:
        pass
    return data


class Task(object):
    def __init__(self):
        self._wait_event = threading.Event()

    def setComplete(self):
        self._wait_event.set()

    def wait(self, timeout=None):
        """Wait for a response from Gearman.

        :arg int timeout: If not None, return after this many seconds if no
            response has been received (default: None).
        """

        self._wait_event.wait(timeout)
        return self._wait_event.is_set()


class SubmitJobTask(Task):
    def __init__(self, job):
        super(SubmitJobTask, self).__init__()
        self.job = job


class OptionReqTask(Task):
    pass


class Connection(object):
    """A Connection to a Gearman Server.

    :arg str client_id: The client ID associated with this connection.
        It will be appending to the name of the logger (e.g.,
        gear.Connection.client_id).  Defaults to 'unknown'.
    """

    def __init__(self, host, port, ssl_key=None, ssl_cert=None, ssl_ca=None,
                 client_id='unknown'):
        self.log = logging.getLogger("gear.Connection.%s" % (client_id,))
        self.host = host
        self.port = port
        self.ssl_key = ssl_key
        self.ssl_cert = ssl_cert
        self.ssl_ca = ssl_ca

        self.use_ssl = False
        if all([self.ssl_key, self.ssl_cert, self.ssl_ca]):
            self.use_ssl = True

        self.echo_lock = threading.Lock()
        self._init()

    def _init(self):
        self.conn = None
        self.connected = False
        self.connect_time = None
        self.related_jobs = {}
        self.pending_tasks = []
        self.admin_requests = []
        self.echo_conditions = {}
        self.options = set()
        self.changeState("INIT")

    def changeState(self, state):
        # The state variables are provided as a convenience (and used by
        # the Worker implementation).  They aren't used or modified within
        # the connection object itself except to reset to "INIT" immediately
        # after reconnection.
        self.log.debug("Setting state to: %s" % state)
        self.state = state
        self.state_time = time.time()

    def __repr__(self):
        return '<gear.Connection 0x%x host: %s port: %s>' % (
            id(self), self.host, self.port)

    def connect(self):
        """Open a connection to the server.

        :raises ConnectionError: If unable to open the socket.
        """

        self.log.debug("Connecting to %s port %s" % (self.host, self.port))
        s = None
        for res in socket.getaddrinfo(self.host, self.port,
                                      socket.AF_UNSPEC, socket.SOCK_STREAM):
            af, socktype, proto, canonname, sa = res
            try:
                s = socket.socket(af, socktype, proto)
            except socket.error:
                s = None
                continue

            if self.use_ssl:
                self.log.debug("Using SSL")
                s = ssl.wrap_socket(s, ssl_version=ssl.PROTOCOL_TLSv1,
                                    cert_reqs=ssl.CERT_REQUIRED,
                                    keyfile=self.ssl_key,
                                    certfile=self.ssl_cert,
                                    ca_certs=self.ssl_ca)

            try:
                s.connect(sa)
            except socket.error:
                s.close()
                s = None
                continue
            break
        if s is None:
            self.log.debug("Error connecting to %s port %s" % (
                self.host, self.port))
            raise ConnectionError("Unable to open socket")
        self.log.info("Connected to %s port %s" % (self.host, self.port))
        self.conn = s
        self.connected = True
        self.connect_time = time.time()

    def disconnect(self):
        """Disconnect from the server and remove all associated state
        data.
        """

        if self.conn:
            try:
                self.conn.close()
            except Exception:
                pass

        self.log.info("Disconnected from %s port %s" % (self.host, self.port))
        self._init()

    def reconnect(self):
        """Disconnect from and reconnect to the server, removing all
        associated state data.
        """
        self.disconnect()
        self.connect()

    def sendRaw(self, data):
        """Send raw data over the socket.

        :arg bytes data The raw data to send
        """
        while True:
            try:
                self.conn.send(data)
            except ssl.SSLError as e:
                if e.errno == ssl.SSL_ERROR_WANT_READ:
                    continue
                elif e.errno == ssl.SSL_ERROR_WANT_WRITE:
                    continue
                else:
                    raise
            break

    def sendPacket(self, packet):
        """Send a packet to the server.

        :arg Packet packet: The :py:class:`Packet` to send.
        """
        self.log.info("Sending packet to %s: %s" % (self, packet))
        self.sendRaw(packet.toBinary())

    def _getAdminRequest(self):
        return self.admin_requests.pop(0)

    def _readRawBytes(self, bytes_to_read):
        while True:
            try:
                buff = self.conn.recv(bytes_to_read)
            except ssl.SSLError as e:
                if e.errno == ssl.SSL_ERROR_WANT_READ:
                    continue
                elif e.errno == ssl.SSL_ERROR_WANT_WRITE:
                    continue
                else:
                    raise
            break

        bytes_read = len(buff)
        if self.use_ssl and (bytes_read < bytes_to_read):
            remaining = self.conn.pending()
            while remaining and (bytes_read < bytes_to_read):
                buff += self.conn.recv(bytes_to_read - bytes_read)
                remaining = self.conn.pending()
                bytes_read = len(buff)

        return buff

    def readPacket(self):
        """Read one packet or administrative response from the server.

        Blocks until the complete packet or response is read.

        :returns: The :py:class:`Packet` or :py:class:`AdminRequest` read.
        :rtype: :py:class:`Packet` or :py:class:`AdminRequest`
        """
        packet = b''
        datalen = 0
        code = None
        ptype = None
        admin = None
        admin_request = None
        while True:
            c = self._readRawBytes(1)
            if not c:
                return None
            if admin is None:
                if c == b'\x00':
                    admin = False
                else:
                    admin = True
                    admin_request = self._getAdminRequest()
            packet += c
            if admin:
                if admin_request.isComplete(packet):
                    return admin_request
            else:
                if len(packet) == 12:
                    code, ptype, datalen = struct.unpack('!4sii', packet)
                if len(packet) == datalen + 12:
                    return Packet(code, ptype, packet[12:], connection=self)

    def sendAdminRequest(self, request, timeout=90):
        """Send an administrative request to the server.

        :arg AdminRequest request: The :py:class:`AdminRequest` to send.
        :arg numeric timeout: Number of seconds to wait until the response
            is received.  If None, wait forever (default: 90 seconds).
        :raises TimeoutError: If the timeout is reached before the response
            is received.
        """
        self.admin_requests.append(request)
        self.sendRaw(request.getCommand())
        complete = request.waitForResponse(timeout)
        if not complete:
            raise TimeoutError()

    def echo(self, data=None, timeout=30):
        """Perform an echo test on the server.

        This method waits until the echo response has been received or the
        timeout has been reached.

        :arg bytes data: The data to request be echoed.  If None, a random
            unique byte string will be generated.
        :arg numeric timeout: Number of seconds to wait until the response
            is received.  If None, wait forever (default: 30 seconds).
        :raises TimeoutError: If the timeout is reached before the response
            is received.
        """
        if data is None:
            data = uuid_module.uuid4().hex.encode('utf8')
        self.echo_lock.acquire()
        try:
            if data in self.echo_conditions:
                raise InvalidDataError("This client is already waiting on an "
                                       "echo response of: %s" % data)
            condition = threading.Condition()
            self.echo_conditions[data] = condition
        finally:
            self.echo_lock.release()

        self.sendEchoReq(data)

        condition.acquire()
        condition.wait(timeout)
        condition.release()

        if data in self.echo_conditions:
            return data
        raise TimeoutError()

    def sendEchoReq(self, data):
        p = Packet(constants.REQ, constants.ECHO_REQ, data)
        self.sendPacket(p)

    def handleEchoRes(self, data):
        condition = None
        self.echo_lock.acquire()
        try:
            condition = self.echo_conditions.get(data)
            if condition:
                del self.echo_conditions[data]
        finally:
            self.echo_lock.release()

        if not condition:
            return False
        condition.notifyAll()
        return True

    def handleOptionRes(self, option):
        self.options.add(option)


class AdminRequest(object):
    """Encapsulates a request (and response) sent over the
    administrative protocol.  This is a base class that may not be
    instantiated dircectly; a subclass implementing a specific command
    must be used instead.

    :arg list arguments: A list of byte string arguments for the command.

    The following instance attributes are available:

    **response** (bytes)
        The response from the server.
    **arguments** (bytes)
        The argument supplied with the constructor.
    **command** (bytes)
        The administrative command.
    """

    command = None
    arguments = []
    response = None

    def __init__(self, *arguments):
        self.wait_event = threading.Event()
        self.arguments = arguments
        if type(self) == AdminRequest:
            raise NotImplementedError("AdminRequest must be subclassed")

    def __repr__(self):
        return '<gear.AdminRequest 0x%x command: %s>' % (
            id(self), self.command)

    def getCommand(self):
        cmd = self.command
        if self.arguments:
            cmd += b' ' + b' '.join(self.arguments)
        cmd += b'\n'
        return cmd

    def isComplete(self, data):
        if (data[-3:] == b'\n.\n' or
            data[-5:] == b'\r\n.\r\n' or
            data == b'.\n' or
            data == b'.\r\n'):
            self.response = data
            return True
        return False

    def setComplete(self):
        self.wait_event.set()

    def waitForResponse(self, timeout=None):
        self.wait_event.wait(timeout)
        return self.wait_event.is_set()


class StatusAdminRequest(AdminRequest):
    """A "status" administrative request.

    The response from gearman may be found in the **response** attribute.
    """
    command = b'status'

    def __init__(self):
        super(StatusAdminRequest, self).__init__()


class ShowJobsAdminRequest(AdminRequest):
    """A "show jobs" administrative request.

    The response from gearman may be found in the **response** attribute.
    """
    command = b'show jobs'

    def __init__(self):
        super(ShowJobsAdminRequest, self).__init__()


class ShowUniqueJobsAdminRequest(AdminRequest):
    """A "show unique jobs" administrative request.

    The response from gearman may be found in the **response** attribute.
    """

    command = b'show unique jobs'

    def __init__(self):
        super(ShowUniqueJobsAdminRequest, self).__init__()


class CancelJobAdminRequest(AdminRequest):
    """A "cancel job" administrative request.

    :arg str handle: The job handle to be canceled.

    The response from gearman may be found in the **response** attribute.
    """

    command = b'cancel job'

    def __init__(self, handle):
        handle = convert_to_bytes(handle)
        super(CancelJobAdminRequest, self).__init__(handle)

    def isComplete(self, data):
        if data[-1:] == b'\n':
            self.response = data
            return True
        return False


class VersionAdminRequest(AdminRequest):
    """A "version" administrative request.

    The response from gearman may be found in the **response** attribute.
    """

    command = b'version'

    def __init__(self):
        super(VersionAdminRequest, self).__init__()

    def isComplete(self, data):
        if data[-1:] == b'\n':
            self.response = data
            return True
        return False


class WorkersAdminRequest(AdminRequest):
    """A "workers" administrative request.

    The response from gearman may be found in the **response** attribute.
    """
    command = b'workers'

    def __init__(self):
        super(WorkersAdminRequest, self).__init__()


class Packet(object):
    """A data packet received from or to be sent over a
    :py:class:`Connection`.

    :arg bytes code: The Gearman magic code (:py:data:`constants.REQ` or
        :py:data:`constants.RES`)
    :arg bytes ptype: The packet type (one of the packet types in
        constants).
    :arg bytes data: The data portion of the packet.
    :arg Connection connection: The connection on which the packet
        was received (optional).
    :raises InvalidDataError: If the magic code is unknown.
    """

    def __init__(self, code, ptype, data, connection=None):
        if not isinstance(code, bytes) and not isinstance(code, bytearray):
            raise TypeError("code must be of type bytes or bytearray")
        if code[0:1] != b'\x00':
            raise InvalidDataError("First byte of packet must be 0")
        self.code = code
        self.ptype = ptype
        if not isinstance(data, bytes) and not isinstance(data, bytearray):
            raise TypeError("data must be of type bytes or bytearray")
        self.data = data
        self.connection = connection

    def __repr__(self):
        ptype = constants.types.get(self.ptype, 'UNKNOWN')
        try:
            extra = self._formatExtraData()
        except Exception:
            extra = ''
        return '<gear.Packet 0x%x type: %s%s>' % (id(self), ptype, extra)

    def _formatExtraData(self):
        if self.ptype in [constants.JOB_CREATED,
                          constants.JOB_ASSIGN,
                          constants.GET_STATUS,
                          constants.STATUS_RES,
                          constants.WORK_STATUS,
                          constants.WORK_COMPLETE,
                          constants.WORK_FAIL,
                          constants.WORK_EXCEPTION,
                          constants.WORK_DATA,
                          constants.WORK_WARNING]:
            return ' handle: %s' % self.getArgument(0)

        if self.ptype == constants.JOB_ASSIGN_UNIQ:
            print self.data
            return (' handle: %s function: %s unique: %s' %
                    (self.getArgument(0),
                     self.getArgument(1),
                     self.getArgument(2)))

        if self.ptype in [constants.SUBMIT_JOB,
                          constants.SUBMIT_JOB_BG,
                          constants.SUBMIT_JOB_HIGH,
                          constants.SUBMIT_JOB_HIGH_BG,
                          constants.SUBMIT_JOB_LOW,
                          constants.SUBMIT_JOB_LOW_BG,
                          constants.SUBMIT_JOB_SCHED,
                          constants.SUBMIT_JOB_EPOCH]:
            return ' function: %s unique: %s' % (self.getArgument(0),
                                                 self.getArgument(1))

        if self.ptype in [constants.CAN_DO,
                          constants.CANT_DO,
                          constants.CAN_DO_TIMEOUT]:
            return ' function: %s' % (self.getArgument(0),)

        if self.ptype == constants.SET_CLIENT_ID:
            return ' id: %s' % (self.getArgument(0),)

        if self.ptype in [constants.OPTION_REQ,
                          constants.OPTION_RES]:
            return ' option: %s' % (self.getArgument(0),)

        if self.ptype == constants.ERROR:
            return ' code: %s message: %s' % (self.getArgument(0),
                                              self.getArgument(1))
        return ''

    def toBinary(self):
        """Return a Gearman wire protocol binary representation of the packet.

        :returns: The packet in binary form.
        :rtype: bytes
        """
        b = struct.pack('!4sii', self.code, self.ptype, len(self.data))
        b = bytearray(b)
        b += self.data
        return b

    def getArgument(self, index, last=False):
        """Get the nth argument from the packet data.

        :arg int index: The argument index to look up.
        :arg bool last: Whether this is the last argument (and thus
            nulls should be ignored)
        :returns: The argument value.
        :rtype: bytes
        """

        parts = self.data.split(b'\x00')
        if not last:
            return parts[index]
        return b'\x00'.join(parts[index:])

    def getJob(self):
        """Get the :py:class:`Job` associated with the job handle in
        this packet.

        :returns: The :py:class:`Job` for this packet.
        :rtype: Job
        :raises UnknownJobError: If the job is not known.
        """
        handle = self.getArgument(0)
        job = self.connection.related_jobs.get(handle)
        if not job:
            raise UnknownJobError()
        return job


class BaseClientServer(object):
    def __init__(self, client_id=None):
        if client_id:
            self.client_id = convert_to_bytes(client_id)
            self.log = logging.getLogger("gear.BaseClientServer.%s" %
                                         (self.client_id,))
        else:
            self.client_id = None
            self.log = logging.getLogger("gear.BaseClientServer")
        self.running = True
        self.active_connections = []
        self.inactive_connections = []

        self.connection_index = -1
        # A lock and notification mechanism to handle not having any
        # current connections
        self.connections_condition = threading.Condition()

        # A pipe to wake up the poll loop in case it needs to restart
        self.wake_read, self.wake_write = os.pipe()

        self.poll_thread = threading.Thread(name="Gearman client poll",
                                            target=self._doPollLoop)
        self.poll_thread.daemon = True
        self.poll_thread.start()
        self.connect_thread = threading.Thread(name="Gearman client connect",
                                               target=self._doConnectLoop)
        self.connect_thread.daemon = True
        self.connect_thread.start()

    def _doConnectLoop(self):
        # Outer run method of the reconnection thread
        while self.running:
            self.connections_condition.acquire()
            while self.running and not self.inactive_connections:
                self.log.debug("Waiting for change in available servers "
                               "to reconnect")
                self.connections_condition.wait()
            self.connections_condition.release()
            self.log.debug("Checking if servers need to be reconnected")
            try:
                if self.running and not self._connectLoop():
                    # Nothing happened
                    time.sleep(2)
            except Exception:
                self.log.exception("Exception in connect loop:")

    def _connectLoop(self):
        # Inner method of the reconnection loop, triggered by
        # a connection change
        success = False
        for conn in self.inactive_connections[:]:
            self.log.debug("Trying to reconnect %s" % conn)
            try:
                conn.reconnect()
            except ConnectionError:
                self.log.debug("Unable to connect to %s" % conn)
                continue
            except Exception:
                self.log.exception("Exception while connecting to %s" % conn)
                continue

            try:
                self._onConnect(conn)
            except Exception:
                self.log.exception("Exception while performing on-connect "
                                   "tasks for %s" % conn)
                continue
            self.connections_condition.acquire()
            self.inactive_connections.remove(conn)
            self.active_connections.append(conn)
            self.connections_condition.notifyAll()
            os.write(self.wake_write, b'1\n')
            self.connections_condition.release()

            try:
                self._onActiveConnection(conn)
            except Exception:
                self.log.exception("Exception while performing active conn "
                                   "tasks for %s" % conn)

            success = True
        return success

    def _onConnect(self, conn):
        # Called immediately after a successful (re-)connection
        pass

    def _onActiveConnection(self, conn):
        # Called immediately after a connection is activated
        pass

    def _lostConnection(self, conn):
        # Called as soon as a connection is detected as faulty.  Remove
        # it and return ASAP and let the connection thread deal with it.
        self.log.debug("Marking %s as disconnected" % conn)
        self.connections_condition.acquire()
        try:
            jobs = conn.related_jobs.values()
            if conn in self.active_connections:
                self.active_connections.remove(conn)
            if conn not in self.inactive_connections:
                self.inactive_connections.append(conn)
        finally:
            self.connections_condition.notifyAll()
            self.connections_condition.release()
        for job in jobs:
            self.handleDisconnect(job)

    def _doPollLoop(self):
        # Outer run method of poll thread.
        while self.running:
            self.connections_condition.acquire()
            while self.running and not self.active_connections:
                self.log.debug("Waiting for change in available connections "
                               "to poll")
                self.connections_condition.wait()
            self.connections_condition.release()
            try:
                self._pollLoop()
            except socket.error, e:
                if e.errno == errno.ECONNRESET:
                    self.log.debug("Connection reset by peer")
                    # This will get logged later at info level as
                    # "Marking ... as disconnected"
            except Exception:
                self.log.exception("Exception in poll loop:")

    def _pollLoop(self):
        # Inner method of poll loop
        self.log.debug("Preparing to poll")
        poll = select.poll()
        bitmask = (select.POLLIN | select.POLLERR |
                   select.POLLHUP | select.POLLNVAL)
        # Reverse mapping of fd -> connection
        conn_dict = {}
        for conn in self.active_connections:
            poll.register(conn.conn.fileno(), bitmask)
            conn_dict[conn.conn.fileno()] = conn
        # Register the wake pipe so that we can break if we need to
        # reconfigure connections
        poll.register(self.wake_read, bitmask)
        while self.running:
            self.log.debug("Polling %s connections" %
                           len(self.active_connections))
            ret = poll.poll()
            for fd, event in ret:
                if fd == self.wake_read:
                    self.log.debug("Woken by pipe")
                    while True:
                        if os.read(self.wake_read, 1) == b'\n':
                            break
                    return
                conn = conn_dict[fd]
                if event & select.POLLIN:
                    self.log.debug("Processing input on %s" % conn)
                    p = conn.readPacket()
                    if p:
                        if isinstance(p, Packet):
                            self.handlePacket(p)
                        else:
                            self.handleAdminRequest(p)
                    else:
                        self.log.debug("Received no data on %s" % conn)
                        self._lostConnection(conn)
                        return
                else:
                    self.log.debug("Received error event on %s" % conn)
                    self._lostConnection(conn)
                    return

    def handlePacket(self, packet):
        """Handle a received packet.

        This method is called whenever a packet is received from any
        connection.  It normally calls the handle method appropriate
        for the specific packet.

        :arg Packet packet: The :py:class:`Packet` that was received.
        """

        self.log.info("Received packet from %s: %s" % (packet.connection,
                                                       packet))
        start = time.time()
        if packet.ptype == constants.JOB_CREATED:
            self.handleJobCreated(packet)
        elif packet.ptype == constants.WORK_COMPLETE:
            self.handleWorkComplete(packet)
        elif packet.ptype == constants.WORK_FAIL:
            self.handleWorkFail(packet)
        elif packet.ptype == constants.WORK_EXCEPTION:
            self.handleWorkException(packet)
        elif packet.ptype == constants.WORK_DATA:
            self.handleWorkData(packet)
        elif packet.ptype == constants.WORK_WARNING:
            self.handleWorkWarning(packet)
        elif packet.ptype == constants.WORK_STATUS:
            self.handleWorkStatus(packet)
        elif packet.ptype == constants.STATUS_RES:
            self.handleStatusRes(packet)
        elif packet.ptype == constants.GET_STATUS:
            self.handleGetStatus(packet)
        elif packet.ptype == constants.JOB_ASSIGN_UNIQ:
            self.handleJobAssignUnique(packet)
        elif packet.ptype == constants.JOB_ASSIGN:
            self.handleJobAssign(packet)
        elif packet.ptype == constants.NO_JOB:
            self.handleNoJob(packet)
        elif packet.ptype == constants.NOOP:
            self.handleNoop(packet)
        elif packet.ptype == constants.SUBMIT_JOB:
            self.handleSubmitJob(packet)
        elif packet.ptype == constants.SUBMIT_JOB_BG:
            self.handleSubmitJobBg(packet)
        elif packet.ptype == constants.SUBMIT_JOB_HIGH:
            self.handleSubmitJobHigh(packet)
        elif packet.ptype == constants.SUBMIT_JOB_HIGH_BG:
            self.handleSubmitJobHighBg(packet)
        elif packet.ptype == constants.SUBMIT_JOB_LOW:
            self.handleSubmitJobLow(packet)
        elif packet.ptype == constants.SUBMIT_JOB_LOW_BG:
            self.handleSubmitJobLowBg(packet)
        elif packet.ptype == constants.SUBMIT_JOB_SCHED:
            self.handleSubmitJobSched(packet)
        elif packet.ptype == constants.SUBMIT_JOB_EPOCH:
            self.handleSubmitJobEpoch(packet)
        elif packet.ptype == constants.GRAB_JOB_UNIQ:
            self.handleGrabJobUniq(packet)
        elif packet.ptype == constants.GRAB_JOB:
            self.handleGrabJob(packet)
        elif packet.ptype == constants.PRE_SLEEP:
            self.handlePreSleep(packet)
        elif packet.ptype == constants.SET_CLIENT_ID:
            self.handleSetClientID(packet)
        elif packet.ptype == constants.CAN_DO:
            self.handleCanDo(packet)
        elif packet.ptype == constants.CAN_DO_TIMEOUT:
            self.handleCanDoTimeout(packet)
        elif packet.ptype == constants.CANT_DO:
            self.handleCantDo(packet)
        elif packet.ptype == constants.RESET_ABILITIES:
            self.handleResetAbilities(packet)
        elif packet.ptype == constants.ECHO_REQ:
            self.handleEchoReq(packet)
        elif packet.ptype == constants.ECHO_RES:
            self.handleEchoRes(packet)
        elif packet.ptype == constants.ERROR:
            self.handleError(packet)
        elif packet.ptype == constants.ALL_YOURS:
            self.handleAllYours(packet)
        elif packet.ptype == constants.OPTION_REQ:
            self.handleOptionReq(packet)
        elif packet.ptype == constants.OPTION_RES:
            self.handleOptionRes(packet)
        else:
            self.log.error("Received unknown packet: %s" % packet)
        end = time.time()
        self.reportTimingStats(packet.ptype, end - start)

    def reportTimingStats(self, ptype, duration):
        """Report processing times by packet type

        This method is called by handlePacket to report how long
        processing took for each packet.  The default implementation
        does nothing.

        :arg bytes ptype: The packet type (one of the packet types in
            constants).
        :arg float duration: The time (in seconds) it took to process
            the packet.
        """
        pass

    def _defaultPacketHandler(self, packet):
        self.log.error("Received unhandled packet: %s" % packet)

    def handleJobCreated(self, packet):
        return self._defaultPacketHandler(packet)

    def handleWorkComplete(self, packet):
        return self._defaultPacketHandler(packet)

    def handleWorkFail(self, packet):
        return self._defaultPacketHandler(packet)

    def handleWorkException(self, packet):
        return self._defaultPacketHandler(packet)

    def handleWorkData(self, packet):
        return self._defaultPacketHandler(packet)

    def handleWorkWarning(self, packet):
        return self._defaultPacketHandler(packet)

    def handleWorkStatus(self, packet):
        return self._defaultPacketHandler(packet)

    def handleStatusRes(self, packet):
        return self._defaultPacketHandler(packet)

    def handleGetStatus(self, packet):
        return self._defaultPacketHandler(packet)

    def handleJobAssignUnique(self, packet):
        return self._defaultPacketHandler(packet)

    def handleJobAssign(self, packet):
        return self._defaultPacketHandler(packet)

    def handleNoJob(self, packet):
        return self._defaultPacketHandler(packet)

    def handleNoop(self, packet):
        return self._defaultPacketHandler(packet)

    def handleSubmitJob(self, packet):
        return self._defaultPacketHandler(packet)

    def handleSubmitJobBg(self, packet):
        return self._defaultPacketHandler(packet)

    def handleSubmitJobHigh(self, packet):
        return self._defaultPacketHandler(packet)

    def handleSubmitJobHighBg(self, packet):
        return self._defaultPacketHandler(packet)

    def handleSubmitJobLow(self, packet):
        return self._defaultPacketHandler(packet)

    def handleSubmitJobLowBg(self, packet):
        return self._defaultPacketHandler(packet)

    def handleSubmitJobSched(self, packet):
        return self._defaultPacketHandler(packet)

    def handleSubmitJobEpoch(self, packet):
        return self._defaultPacketHandler(packet)

    def handleGrabJobUniq(self, packet):
        return self._defaultPacketHandler(packet)

    def handleGrabJob(self, packet):
        return self._defaultPacketHandler(packet)

    def handlePreSleep(self, packet):
        return self._defaultPacketHandler(packet)

    def handleSetClientID(self, packet):
        return self._defaultPacketHandler(packet)

    def handleCanDo(self, packet):
        return self._defaultPacketHandler(packet)

    def handleCanDoTimeout(self, packet):
        return self._defaultPacketHandler(packet)

    def handleCantDo(self, packet):
        return self._defaultPacketHandler(packet)

    def handleResetAbilities(self, packet):
        return self._defaultPacketHandler(packet)

    def handleEchoReq(self, packet):
        return self._defaultPacketHandler(packet)

    def handleEchoRes(self, packet):
        return self._defaultPacketHandler(packet)

    def handleError(self, packet):
        return self._defaultPacketHandler(packet)

    def handleAllYours(self, packet):
        return self._defaultPacketHandler(packet)

    def handleOptionReq(self, packet):
        return self._defaultPacketHandler(packet)

    def handleOptionRes(self, packet):
        return self._defaultPacketHandler(packet)

    def handleAdminRequest(self, request):
        """Handle an administrative command response from Gearman.

        This method is called whenever a response to a previously
        issued administrative command is received from one of this
        client's connections.  It normally releases the wait lock on
        the initiating AdminRequest object.

        :arg AdminRequest request: The :py:class:`AdminRequest` that
            initiated the received response.
        """

        self.log.info("Received admin data %s" % request)
        request.setComplete()

    def shutdown(self):
        """Close all connections and stop all running threads.

        The object may no longer be used after shutdown is called.
        """
        self.log.debug("Beginning shutdown")
        self._shutdown()
        self.log.debug("Beginning cleanup")
        self._cleanup()
        self.log.debug("Finished shutdown")

    def _shutdown(self):
        # The first part of the shutdown process where all threads
        # are told to exit.
        self.running = False
        self.connections_condition.acquire()
        try:
            self.connections_condition.notifyAll()
            os.write(self.wake_write, b'1\n')
        finally:
            self.connections_condition.release()

    def _cleanup(self):
        # The second part of the shutdown process where we wait for all
        # threads to exit and then clean up.
        self.poll_thread.join()
        self.connect_thread.join()
        for connection in self.active_connections:
            connection.disconnect()
        self.active_connections = []
        self.inactive_connections = []
        os.close(self.wake_read)
        os.close(self.wake_write)


class BaseClient(BaseClientServer):
    def __init__(self, client_id='unknown'):
        super(BaseClient, self).__init__(client_id)
        self.log = logging.getLogger("gear.BaseClient.%s" % (self.client_id,))
        # A lock to use when sending packets that set the state across
        # all known connections.  Note that it doesn't necessarily need
        # to be used for all broadcasts, only those that affect multi-
        # connection state, such as setting options or functions.
        self.broadcast_lock = threading.RLock()

    def addServer(self, host, port=4730,
                  ssl_key=None, ssl_cert=None, ssl_ca=None):
        """Add a server to the client's connection pool.

        Any number of Gearman servers may be added to a client.  The
        client will connect to all of them and send jobs to them in a
        round-robin fashion.  When servers are disconnected, the
        client will automatically remove them from the pool,
        continuously try to reconnect to them, and return them to the
        pool when reconnected.  New servers may be added at any time.

        This is a non-blocking call that will return regardless of
        whether the initial connection succeeded.  If you need to
        ensure that a connection is ready before proceeding, see
        :py:meth:`waitForServer`.

        When using SSL connections, all SSL files must be specified.

        :arg str host: The hostname or IP address of the server.
        :arg int port: The port on which the gearman server is listening.
        :arg str ssl_key: Path to the SSL private key.
        :arg str ssl_cert: Path to the SSL certificate.
        :arg str ssl_ca: Path to the CA certificate.
        :raises ConfigurationError: If the host/port combination has
            already been added to the client.
        """

        self.log.debug("Adding server %s port %s" % (host, port))

        self.connections_condition.acquire()
        try:
            for conn in self.active_connections + self.inactive_connections:
                if conn.host == host and conn.port == port:
                    raise ConfigurationError("Host/port already specified")
            conn = Connection(host, port, ssl_key, ssl_cert, ssl_ca,
                              self.client_id)
            self.inactive_connections.append(conn)
            self.connections_condition.notifyAll()
        finally:
            self.connections_condition.release()

    def waitForServer(self):
        """Wait for at least one server to be connected.

        Block until at least one gearman server is connected.
        """
        connected = False
        while self.running:
            self.connections_condition.acquire()
            while self.running and not self.active_connections:
                self.log.debug("Waiting for at least one active connection")
                self.connections_condition.wait()
            if self.active_connections:
                self.log.debug("Active connection found")
                connected = True
            self.connections_condition.release()
            if connected:
                return

    def getConnection(self):
        """Return a connected server.

        Finds the next scheduled connected server in the round-robin
        rotation and returns it.  It is not usually necessary to use
        this method external to the library, as more consumer-oriented
        methods such as submitJob already use it internally, but is
        available nonetheless if necessary.

        :returns: The next scheduled :py:class:`Connection` object.
        :rtype: :py:class:`Connection`
        :raises NoConnectedServersError: If there are not currently
            connected servers.
        """

        conn = None
        try:
            self.connections_condition.acquire()
            if not self.active_connections:
                raise NoConnectedServersError("No connected Gearman servers")

            self.connection_index += 1
            if self.connection_index >= len(self.active_connections):
                self.connection_index = 0
            conn = self.active_connections[self.connection_index]
        finally:
            self.connections_condition.release()
        return conn

    def broadcast(self, packet):
        """Send a packet to all currently connected servers.

        :arg Packet packet: The :py:class:`Packet` to send.
        """
        connections = self.active_connections[:]
        for connection in connections:
            try:
                self.sendPacket(packet, connection)
            except Exception:
                # Error handling is all done by sendPacket
                pass

    def sendPacket(self, packet, connection):
        """Send a packet to a single connection, removing it from the
        list of active connections if that fails.

        :arg Packet packet: The :py:class:`Packet` to send.
        :arg Connection connection: The :py:class:`Connection` on
            which to send the packet.
        """
        try:
            connection.sendPacket(packet)
            return
        except Exception:
            self.log.exception("Exception while sending packet %s to %s" %
                               (packet, connection))
                # If we can't send the packet, discard the connection
            self._lostConnection(connection)
            raise

    def handleEchoRes(self, packet):
        """Handle an ECHO_RES packet.

        Causes the blocking :py:meth:`Connection.echo` invocation to
        return.

        :arg Packet packet: The :py:class:`Packet` that was received.
        :returns: None
        """
        packet.connection.handleEchoRes(packet.getArgument(0, True))

    def handleError(self, packet):
        """Handle an ERROR packet.

        Logs the error.

        :arg Packet packet: The :py:class:`Packet` that was received.
        :returns: None
        """
        self.log.error("Received ERROR packet: %s: %s" %
                       (packet.getArgument(0),
                        packet.getArgument(1)))
        try:
            task = packet.connection.pending_tasks.pop(0)
            task.setComplete()
        except Exception:
            self.log.exception("Exception while handling error packet:")
            self._lostConnection(packet.connection)


class Client(BaseClient):
    """A Gearman client.

    You may wish to subclass this class in order to override the
    default event handlers to react to Gearman events.  Be sure to
    call the superclass event handlers so that they may perform
    job-related housekeeping.

    :arg str client_id: The client ID to provide to Gearman.  It will
        appear in administrative output and be appended to the name of
        the logger (e.g., gear.Client.client_id).  Defaults to
        'unknown'.
    """

    def __init__(self, client_id='unknown'):
        super(Client, self).__init__(client_id)
        self.log = logging.getLogger("gear.Client.%s" % (self.client_id,))
        self.options = set()

    def __repr__(self):
        return '<gear.Client 0x%x>' % id(self)

    def _onConnect(self, conn):
        # Called immediately after a successful (re-)connection
        self.broadcast_lock.acquire()
        try:
            super(Client, self)._onConnect(conn)
            for name in self.options:
                self._setOptionConnection(name, conn)
        finally:
            self.broadcast_lock.release()

    def _setOptionConnection(self, name, conn):
        # Set an option on a connection
        packet = Packet(constants.REQ, constants.OPTION_REQ, name)
        task = OptionReqTask()
        try:
            conn.pending_tasks.append(task)
            self.sendPacket(packet, conn)
        except Exception:
            # Error handling is all done by sendPacket
            task = None
        return task

    def setOption(self, name, timeout=30):
        """Set an option for all connections.

        :arg str name: The option name to set.
        :arg int timeout: How long to wait (in seconds) for a response
            from the server before giving up (default: 30 seconds).
        :returns: True if the option was set on all connections,
            otherwise False
        :rtype: bool
        """
        tasks = {}
        name = convert_to_bytes(name)
        self.broadcast_lock.acquire()

        try:
            self.options.add(name)
            connections = self.active_connections[:]
            for connection in connections:
                task = self._setOptionConnection(name, connection)
                if task:
                    tasks[task] = connection
        finally:
            self.broadcast_lock.release()

        success = True
        for task in tasks.keys():
            complete = task.wait(timeout)
            conn = tasks[task]
            if not complete:
                self.log.error("Connection %s timed out waiting for a "
                               "response to an option request: %s" %
                               (conn, name))
                self._lostConnection(conn)
                continue
            if name not in conn.options:
                success = False
        return success

    def submitJob(self, job, background=False, precedence=PRECEDENCE_NORMAL,
                  timeout=30):
        """Submit a job to a Gearman server.

        Submits the provided job to the next server in this client's
        round-robin connection pool.

        If the job is a foreground job, updates will be made to the
        supplied :py:class:`Job` object as they are received.

        :arg Job job: The :py:class:`Job` to submit.
        :arg bool background: Whether the job should be backgrounded.
        :arg int precedence: Whether the job should have normal, low, or
            high precedence.  One of :py:data:`PRECEDENCE_NORMAL`,
            :py:data:`PRECEDENCE_LOW`, or :py:data:`PRECEDENCE_HIGH`
        :arg int timeout: How long to wait (in seconds) for a response
            from the server before giving up (default: 30 seconds).
        :raises ConfigurationError: If an invalid precendence value
            is supplied.
        """
        if job.unique is None:
            unique = b''
        else:
            unique = job.unique
        data = b'\x00'.join((job.name, unique, job.arguments))
        if background:
            if precedence == PRECEDENCE_NORMAL:
                cmd = constants.SUBMIT_JOB_BG
            elif precedence == PRECEDENCE_LOW:
                cmd = constants.SUBMIT_JOB_LOW_BG
            elif precedence == PRECEDENCE_HIGH:
                cmd = constants.SUBMIT_JOB_HIGH_BG
            else:
                raise ConfigurationError("Invalid precedence value")
        else:
            if precedence == PRECEDENCE_NORMAL:
                cmd = constants.SUBMIT_JOB
            elif precedence == PRECEDENCE_LOW:
                cmd = constants.SUBMIT_JOB_LOW
            elif precedence == PRECEDENCE_HIGH:
                cmd = constants.SUBMIT_JOB_HIGH
            else:
                raise ConfigurationError("Invalid precedence value")
        packet = Packet(constants.REQ, cmd, data)
        attempted_connections = set()
        while True:
            if attempted_connections == set(self.active_connections):
                break
            conn = self.getConnection()
            task = SubmitJobTask(job)
            conn.pending_tasks.append(task)
            attempted_connections.add(conn)
            try:
                self.sendPacket(packet, conn)
            except Exception:
                # Error handling is all done by sendPacket
                continue
            complete = task.wait(timeout)
            if not complete:
                self.log.error("Connection %s timed out waiting for a "
                               "response to a submit job request: %s" %
                               (conn, job))
                self._lostConnection(conn)
                continue
            if not job.handle:
                self.log.error("Connection %s sent an error in "
                               "response to a submit job request: %s" %
                               (conn, job))
                continue
            job.connection = conn
            return
        raise GearmanError("Unable to submit job to any connected servers")

    def handleJobCreated(self, packet):
        """Handle a JOB_CREATED packet.

        Updates the appropriate :py:class:`Job` with the newly
        returned job handle.

        :arg Packet packet: The :py:class:`Packet` that was received.
        :returns: The :py:class:`Job` object associated with the job request.
        :rtype: :py:class:`Job`
        """
        task = packet.connection.pending_tasks.pop(0)
        if not isinstance(task, SubmitJobTask):
            msg = ("Unexpected response received to submit job "
                   "request: %s" % packet)
            self.log.error(msg)
            self._lostConnection(packet.connection)
            raise GearmanError(msg)

        job = task.job
        job.handle = packet.data
        packet.connection.related_jobs[job.handle] = job
        task.setComplete()
        self.log.debug("Job created; handle: %s" % job.handle)
        return job

    def handleWorkComplete(self, packet):
        """Handle a WORK_COMPLETE packet.

        Updates the referenced :py:class:`Job` with the returned data
        and removes it from the list of jobs associated with the
        connection.

        :arg Packet packet: The :py:class:`Packet` that was received.
        :returns: The :py:class:`Job` object associated with the job request.
        :rtype: :py:class:`Job`
        """

        job = packet.getJob()
        data = packet.getArgument(1, True)
        if data:
            job.data.append(data)
        job.complete = True
        job.failure = False
        del packet.connection.related_jobs[job.handle]
        self.log.debug("Job complete; handle: %s data: %s" %
                       (job.handle, job.data))
        return job

    def handleWorkFail(self, packet):
        """Handle a WORK_FAIL packet.

        Updates the referenced :py:class:`Job` with the returned data
        and removes it from the list of jobs associated with the
        connection.

        :arg Packet packet: The :py:class:`Packet` that was received.
        :returns: The :py:class:`Job` object associated with the job request.
        :rtype: :py:class:`Job`
        """

        job = packet.getJob()
        job.complete = True
        job.failure = True
        del packet.connection.related_jobs[job.handle]
        self.log.debug("Job failed; handle: %s" % job.handle)
        return job

    def handleWorkException(self, packet):
        """Handle a WORK_Exception packet.

        Updates the referenced :py:class:`Job` with the returned data
        and removes it from the list of jobs associated with the
        connection.

        :arg Packet packet: The :py:class:`Packet` that was received.
        :returns: The :py:class:`Job` object associated with the job request.
        :rtype: :py:class:`Job`
        """

        job = packet.getJob()
        job.exception = packet.getArgument(1, True)
        job.complete = True
        job.failure = True
        del packet.connection.related_jobs[job.handle]
        self.log.debug("Job exception; handle: %s data: %s" %
                       (job.handle, job.exception))
        return job

    def handleWorkData(self, packet):
        """Handle a WORK_DATA packet.

        Updates the referenced :py:class:`Job` with the returned data.

        :arg Packet packet: The :py:class:`Packet` that was received.
        :returns: The :py:class:`Job` object associated with the job request.
        :rtype: :py:class:`Job`
        """

        job = packet.getJob()
        data = packet.getArgument(1, True)
        if data:
            job.data.append(data)
        self.log.debug("Job data; handle: %s data: %s" %
                       (job.handle, job.data))
        return job

    def handleWorkWarning(self, packet):
        """Handle a WORK_WARNING packet.

        Updates the referenced :py:class:`Job` with the returned data.

        :arg Packet packet: The :py:class:`Packet` that was received.
        :returns: The :py:class:`Job` object associated with the job request.
        :rtype: :py:class:`Job`
        """

        job = packet.getJob()
        data = packet.getArgument(1, True)
        if data:
            job.data.append(data)
        job.warning = True
        self.log.debug("Job warning; handle: %s data: %s" %
                       (job.handle, job.data))
        return job

    def handleWorkStatus(self, packet):
        """Handle a WORK_STATUS packet.

        Updates the referenced :py:class:`Job` with the returned data.

        :arg Packet packet: The :py:class:`Packet` that was received.
        :returns: The :py:class:`Job` object associated with the job request.
        :rtype: :py:class:`Job`
        """

        job = packet.getJob()
        job.numerator = packet.getArgument(1)
        job.denominator = packet.getArgument(2)
        try:
            job.fraction_complete = (float(job.numerator) /
                                     float(job.denominator))
        except Exception:
            job.fraction_complete = None
        self.log.debug("Job status; handle: %s complete: %s/%s" %
                       (job.handle, job.numerator, job.denominator))
        return job

    def handleStatusRes(self, packet):
        """Handle a STATUS_RES packet.

        Updates the referenced :py:class:`Job` with the returned data.

        :arg Packet packet: The :py:class:`Packet` that was received.
        :returns: The :py:class:`Job` object associated with the job request.
        :rtype: :py:class:`Job`
        """

        job = packet.getJob()
        job.known = (packet.getArgument(1) == '1')
        job.running = (packet.getArgument(2) == '1')
        job.numerator = packet.getArgument(3)
        job.denominator = packet.getArgument(4)

        try:
            job.fraction_complete = (float(job.numerator) /
                                     float(job.denominator))
        except Exception:
            job.fraction_complete = None
        return job

    def handleOptionRes(self, packet):
        """Handle an OPTION_RES packet.

        Updates the set of options for the connection.

        :arg Packet packet: The :py:class:`Packet` that was received.
        :returns: None.
        """
        task = packet.connection.pending_tasks.pop(0)
        if not isinstance(task, OptionReqTask):
            msg = ("Unexpected response received to option "
                   "request: %s" % packet)
            self.log.error(msg)
            self._lostConnection(packet.connection)
            raise GearmanError(msg)

        packet.connection.handleOptionRes(packet.getArgument(0))
        task.setComplete()

    def handleDisconnect(self, job):
        """Handle a Gearman server disconnection.

        If the Gearman server is disconnected, this will be called for any
        jobs currently associated with the server.

        :arg Job packet: The :py:class:`Job` that was running when the server
            disconnected.
        """
        return job


class FunctionRecord(object):
    """Represents a function that should be registered with Gearman.

    This class only directly needs to be instatiated for use with
    :py:meth:`Worker.setFunctions`.  If a timeout value is supplied,
    the function will be registered with CAN_DO_TIMEOUT.

    :arg str name: The name of the function to register.
    :arg numeric timeout: The timeout value (optional).
    """
    def __init__(self, name, timeout=None):
        self.name = name
        self.timeout = timeout

    def __repr__(self):
        return '<gear.FunctionRecord 0x%x name: %s timeout: %s>' % (
            id(self), self.name, self.timeout)


class Worker(BaseClient):
    """A Gearman worker.

    :arg str client_id: The client ID to provide to Gearman.  It will
        appear in administrative output and be appended to the name of
        the logger (e.g., gear.Worker.client_id).
    :arg str worker_id: The client ID to provide to Gearman.  It will
        appear in administrative output and be appended to the name of
        the logger (e.g., gear.Worker.client_id).  This parameter name
        is deprecated, use client_id instead.
    """

    def __init__(self, client_id=None, worker_id=None):
        if not client_id or worker_id:
            raise Exception("A client_id must be provided")
        if worker_id:
            client_id = worker_id
        super(Worker, self).__init__(client_id)
        self.log = logging.getLogger("gear.Worker.%s" % (self.client_id,))
        self.worker_id = client_id
        self.functions = {}
        self.job_lock = threading.Lock()
        self.waiting_for_jobs = 0
        self.job_queue = queue.Queue()

    def __repr__(self):
        return '<gear.Worker 0x%x>' % id(self)

    def registerFunction(self, name, timeout=None):
        """Register a function with Gearman.

        If a timeout value is supplied, the function will be
        registered with CAN_DO_TIMEOUT.

        :arg str name: The name of the function to register.
        :arg numeric timeout: The timeout value (optional).
        """
        name = convert_to_bytes(name)
        self.functions[name] = FunctionRecord(name, timeout)
        if timeout:
            self._sendCanDoTimeout(name, timeout)
        else:
            self._sendCanDo(name)

    def unRegisterFunction(self, name):
        """Remove a function from Gearman's registry.

        :arg str name: The name of the function to remove.
        """
        name = convert_to_bytes(name)
        del self.functions[name]
        self._sendCantDo(name)

    def setFunctions(self, functions):
        """Replace the set of functions registered with Gearman.

        Accepts a list of :py:class:`FunctionRecord` objects which
        represents the complete set of functions that should be
        registered with Gearman.  Any existing functions will be
        unregistered and these registered in their place.  If the
        empty list is supplied, then the Gearman registered function
        set will be cleared.

        :arg list functions: A list of :py:class:`FunctionRecord` objects.
        """

        self._sendResetAbilities()
        self.functions = {}
        for f in functions:
            if not isinstance(f, FunctionRecord):
                raise InvalidDataError(
                    "An iterable of FunctionRecords is required.")
            self.functions[f.name] = f
        for f in self.functions.values():
            if f.timeout:
                self._sendCanDoTimeout(f.name, f.timeout)
            else:
                self._sendCanDo(f.name)

    def _sendCanDo(self, name):
        self.broadcast_lock.acquire()
        try:
            p = Packet(constants.REQ, constants.CAN_DO, name)
            self.broadcast(p)
        finally:
            self.broadcast_lock.release()

    def _sendCanDoTimeout(self, name, timeout):
        self.broadcast_lock.acquire()
        try:
            data = name + b'\x00' + timeout
            p = Packet(constants.REQ, constants.CAN_DO_TIMEOUT, data)
            self.broadcast(p)
        finally:
            self.broadcast_lock.release()

    def _sendCantDo(self, name):
        self.broadcast_lock.acquire()
        try:
            p = Packet(constants.REQ, constants.CANT_DO, name)
            self.broadcast(p)
        finally:
            self.broadcast_lock.release()

    def _sendResetAbilities(self):
        self.broadcast_lock.acquire()
        try:
            p = Packet(constants.REQ, constants.RESET_ABILITIES, b'')
            self.broadcast(p)
        finally:
            self.broadcast_lock.release()

    def _sendPreSleep(self, connection):
        p = Packet(constants.REQ, constants.PRE_SLEEP, b'')
        self.sendPacket(p, connection)

    def _sendGrabJobUniq(self, connection=None):
        p = Packet(constants.REQ, constants.GRAB_JOB_UNIQ, b'')
        if connection:
            self.sendPacket(p, connection)
        else:
            self.broadcast(p)

    def _onConnect(self, conn):
        self.broadcast_lock.acquire()
        try:
            # Called immediately after a successful (re-)connection
            p = Packet(constants.REQ, constants.SET_CLIENT_ID, self.client_id)
            conn.sendPacket(p)
            super(Worker, self)._onConnect(conn)
            for f in self.functions.values():
                if f.timeout:
                    data = f.name + b'\x00' + f.timeout
                    p = Packet(constants.REQ, constants.CAN_DO_TIMEOUT, data)
                else:
                    p = Packet(constants.REQ, constants.CAN_DO, f.name)
                conn.sendPacket(p)
            conn.changeState("IDLE")
        finally:
            self.broadcast_lock.release()
        # Any exceptions will be handled by the calling function, and the
        # connection will not be put into the pool.

    def _onActiveConnection(self, conn):
        self.job_lock.acquire()
        try:
            if self.waiting_for_jobs > 0:
                self._updateStateMachines()
        finally:
            self.job_lock.release()

    def _updateStateMachines(self):
        connections = self.active_connections[:]

        for connection in connections:
            if (connection.state == "IDLE" and self.waiting_for_jobs > 0):
                self._sendGrabJobUniq(connection)
                connection.changeState("GRAB_WAIT")
            if (connection.state != "IDLE" and self.waiting_for_jobs < 1):
                connection.changeState("IDLE")

    def getJob(self):
        """Get a job from Gearman.

        Blocks until a job is received.  This method is re-entrant, so
        it is safe to call this method on a single worker from
        multiple threads.  In that case, one of them at random will
        receive the job assignment.

        :returns: The :py:class:`WorkerJob` assigned.
        :rtype: :py:class:`WorkerJob`.
        :raises InterruptedError: If interrupted (by
            :py:meth:`stopWaitingForJobs`) before a job is received.
        """
        self.job_lock.acquire()
        try:
            self.waiting_for_jobs += 1
            self.log.debug("Get job; number of threads waiting for jobs: %s" %
                           self.waiting_for_jobs)

            try:
                job = self.job_queue.get(False)
            except queue.Empty:
                job = None

            if not job:
                self._updateStateMachines()
        finally:
            self.job_lock.release()

        if not job:
            job = self.job_queue.get()

        self.log.debug("Received job: %s" % job)
        if job is None:
            raise InterruptedError()
        return job

    def stopWaitingForJobs(self):
        """Interrupts all running :py:meth:`getJob` calls, which will raise
        an exception.
        """

        self.job_lock.acquire()
        try:
            while True:
                connections = self.active_connections[:]
                now = time.time()
                ok = True
                for connection in connections:
                    if connection.state == "GRAB_WAIT":
                        # Replies to GRAB_JOB should be fast, give up if we've
                        # been waiting for more than 5 seconds.
                        if now - connection.state_time > 5:
                            self._lostConnection(connection)
                        else:
                            ok = False
                if ok:
                    break
                else:
                    self.job_lock.release()
                    time.sleep(0.1)
                    self.job_lock.acquire()

            while self.waiting_for_jobs > 0:
                self.waiting_for_jobs -= 1
                self.job_queue.put(None)

            self._updateStateMachines()
        finally:
            self.job_lock.release()

    def _shutdown(self):
        super(Worker, self)._shutdown()
        self.stopWaitingForJobs()

    def handleNoop(self, packet):
        """Handle a NOOP packet.

        Sends a GRAB_JOB_UNIQ packet on the same connection.
        GRAB_JOB_UNIQ will return jobs regardless of whether they have
        been specified with a unique identifier when submitted.  If
        they were not, then :py:attr:`WorkerJob.unique` attribute
        will be None.

        :arg Packet packet: The :py:class:`Packet` that was received.
        """

        self.job_lock.acquire()
        try:
            if packet.connection.state == "SLEEP":
                self.log.debug("Sending GRAB_JOB_UNIQ")
                self._sendGrabJobUniq(packet.connection)
                packet.connection.changeState("GRAB_WAIT")
            else:
                self.log.debug("Received unexpecetd NOOP packet on %s" %
                               packet.connection)
        finally:
            self.job_lock.release()

    def handleNoJob(self, packet):
        """Handle a NO_JOB packet.

        Sends a PRE_SLEEP packet on the same connection.

        :arg Packet packet: The :py:class:`Packet` that was received.
        """
        self.job_lock.acquire()
        try:
            if packet.connection.state == "GRAB_WAIT":
                self.log.debug("Sending PRE_SLEEP")
                self._sendPreSleep(packet.connection)
                packet.connection.changeState("SLEEP")
            else:
                self.log.debug("Received unexpected NO_JOB packet on %s" %
                               packet.connection)
        finally:
            self.job_lock.release()

    def handleJobAssign(self, packet):
        """Handle a JOB_ASSIGN packet.

        Adds a WorkerJob to the internal queue to be picked up by any
        threads waiting in :py:meth:`getJob`.

        :arg Packet packet: The :py:class:`Packet` that was received.
        """

        handle = packet.getArgument(0)
        name = packet.getArgument(1)
        arguments = packet.getArgument(2, True)
        return self._handleJobAssignment(packet, handle, name,
                                         arguments, None)

    def handleJobAssignUnique(self, packet):
        """Handle a JOB_ASSIGN_UNIQ packet.

        Adds a WorkerJob to the internal queue to be picked up by any
        threads waiting in :py:meth:`getJob`.

        :arg Packet packet: The :py:class:`Packet` that was received.
        """

        handle = packet.getArgument(0)
        name = packet.getArgument(1)
        unique = packet.getArgument(2)
        if unique == b'':
            unique = None
        arguments = packet.getArgument(3, True)
        return self._handleJobAssignment(packet, handle, name,
                                         arguments, unique)

    def _handleJobAssignment(self, packet, handle, name, arguments, unique):
        job = WorkerJob(handle, name, arguments, unique)
        job.connection = packet.connection

        self.job_lock.acquire()
        try:
            packet.connection.changeState("IDLE")
            self.waiting_for_jobs -= 1
            self.log.debug("Job assigned; number of threads waiting for "
                           "jobs: %s" % self.waiting_for_jobs)
            self.job_queue.put(job)

            self._updateStateMachines()
        finally:
            self.job_lock.release()


class BaseJob(object):
    def __init__(self, name, arguments, unique=None, handle=None):
        self.name = convert_to_bytes(name)
        if (not isinstance(arguments, bytes) and
            not isinstance(arguments, bytearray)):
            raise TypeError("arguments must be of type bytes or bytearray")
        self.arguments = arguments
        self.unique = convert_to_bytes(unique)
        self.handle = handle
        self.connection = None

    def __repr__(self):
        return '<gear.Job 0x%x handle: %s name: %s unique: %s>' % (
            id(self), self.handle, self.name, self.unique)


class Job(BaseJob):
    """A job to run or being run by Gearman.

    :arg str name: The name of the job.
    :arg bytes arguments: The opaque data blob to be passed to the worker
        as arguments.
    :arg str unique: A byte string to uniquely identify the job to Gearman
        (optional).

    The following instance attributes are available:

    **name** (str)
        The name of the job.
    **arguments** (bytes)
        The opaque data blob passed to the worker as arguments.
    **unique** (str or None)
        The unique ID of the job (if supplied).
    **handle** (bytes or None)
        The Gearman job handle.  None if no job handle has been received yet.
    **data** (list of byte-arrays)
        The result data returned from Gearman.  Each packet appends an
        element to the list.  Depending on the nature of the data, the
        elements may need to be concatenated before use.
    **exception** (bytes or None)
        Exception information returned from Gearman.  None if no exception
        has been received.
    **warning** (bool)
        Whether the worker has reported a warning.
    **complete** (bool)
        Whether the job is complete.
    **failure** (bool)
        Whether the job has failed.  Only set when complete is True.
    **numerator** (bytes or None)
        The numerator of the completion ratio reported by the worker.
        Only set when a status update is sent by the worker.
    **denominator** (bytes or None)
        The denominator of the completion ratio reported by the
        worker.  Only set when a status update is sent by the worker.
    **fraction_complete** (float or None)
        The fractional complete ratio reported by the worker.  Only set when
        a status update is sent by the worker.
    **known** (bool or None)
        Whether the job is known to Gearman.  Only set by handleStatusRes() in
        response to a getStatus() query.
    **running** (bool or None)
        Whether the job is running.  Only set by handleStatusRes() in
        response to a getStatus() query.
    **connection** (:py:class:`Connection` or None)
        The connection associated with the job.  Only set after the job
        has been submitted to a Gearman server.
    """

    def __init__(self, name, arguments, unique=None):
        super(Job, self).__init__(name, arguments, unique)
        self.data = []
        self.exception = None
        self.warning = False
        self.complete = False
        self.failure = False
        self.numerator = None
        self.denominator = None
        self.fraction_complete = None
        self.known = None
        self.running = None


class WorkerJob(BaseJob):
    """A job that Gearman has assigned to a Worker.  Not intended to
    be instantiated directly, but rather returned by
    :py:meth:`Worker.getJob`.

    :arg str handle: The job handle assigned by gearman.
    :arg str name: The name of the job.
    :arg bytes arguments: The opaque data blob passed to the worker
        as arguments.
    :arg str unique: A byte string to uniquely identify the job to Gearman
        (optional).

    The following instance attributes are available:

    **name** (str)
        The name of the job.
    **arguments** (bytes)
        The opaque data blob passed to the worker as arguments.
    **unique** (str or None)
        The unique ID of the job (if supplied).
    **handle** (bytes)
        The Gearman job handle.
    **connection** (:py:class:`Connection` or None)
        The connection associated with the job.  Only set after the job
        has been submitted to a Gearman server.
    """

    def __init__(self, handle, name, arguments, unique=None):
        super(WorkerJob, self).__init__(name, arguments, unique, handle)

    def sendWorkData(self, data=b''):
        """Send a WORK_DATA packet to the client.

        :arg bytes data: The data to be sent to the client (optional).
        """

        data = self.handle + b'\x00' + data
        p = Packet(constants.REQ, constants.WORK_DATA, data)
        self.connection.sendPacket(p)

    def sendWorkWarning(self, data=b''):
        """Send a WORK_WARNING packet to the client.

        :arg bytes data: The data to be sent to the client (optional).
        """

        data = self.handle + b'\x00' + data
        p = Packet(constants.REQ, constants.WORK_WARNING, data)
        self.connection.sendPacket(p)

    def sendWorkStatus(self, numerator, denominator):
        """Send a WORK_STATUS packet to the client.

        Sends a numerator and denominator that together represent the
        fraction complete of the job.

        :arg numeric numerator: The numerator of the fraction complete.
        :arg numeric denominator: The denominator of the fraction complete.
        """

        data = (self.handle + b'\x00' +
                str(numerator).encode('utf8') + b'\x00' +
                str(denominator).encode('utf8'))
        p = Packet(constants.REQ, constants.WORK_STATUS, data)
        self.connection.sendPacket(p)

    def sendWorkComplete(self, data=b''):
        """Send a WORK_COMPLETE packet to the client.

        :arg bytes data: The data to be sent to the client (optional).
        """

        data = self.handle + b'\x00' + data
        p = Packet(constants.REQ, constants.WORK_COMPLETE, data)
        self.connection.sendPacket(p)

    def sendWorkFail(self):
        "Send a WORK_FAIL packet to the client."

        p = Packet(constants.REQ, constants.WORK_FAIL, self.handle)
        self.connection.sendPacket(p)

    def sendWorkException(self, data=b''):
        """Send a WORK_EXCEPTION packet to the client.

        :arg bytes data: The exception data to be sent to the client
            (optional).
        """

        data = self.handle + b'\x00' + data
        p = Packet(constants.REQ, constants.WORK_EXCEPTION, data)
        self.connection.sendPacket(p)


# Below are classes for use in the server implementation:
class ServerJob(Job):
    """A job record for use in a server.

    :arg str name: The name of the job.
    :arg bytes arguments: The opaque data blob to be passed to the worker
        as arguments.
    :arg str unique: A byte string to uniquely identify the job to Gearman
        (optional).

    The following instance attributes are available:

    **name** (str)
        The name of the job.
    **arguments** (bytes)
        The opaque data blob passed to the worker as arguments.
    **unique** (str or None)
        The unique ID of the job (if supplied).
    **handle** (bytes or None)
        The Gearman job handle.  None if no job handle has been received yet.
    **data** (list of byte-arrays)
        The result data returned from Gearman.  Each packet appends an
        element to the list.  Depending on the nature of the data, the
        elements may need to be concatenated before use.
    **exception** (bytes or None)
        Exception information returned from Gearman.  None if no exception
        has been received.
    **warning** (bool)
        Whether the worker has reported a warning.
    **complete** (bool)
        Whether the job is complete.
    **failure** (bool)
        Whether the job has failed.  Only set when complete is True.
    **numerator** (bytes or None)
        The numerator of the completion ratio reported by the worker.
        Only set when a status update is sent by the worker.
    **denominator** (bytes or None)
        The denominator of the completion ratio reported by the
        worker.  Only set when a status update is sent by the worker.
    **fraction_complete** (float or None)
        The fractional complete ratio reported by the worker.  Only set when
        a status update is sent by the worker.
    **known** (bool or None)
        Whether the job is known to Gearman.  Only set by handleStatusRes() in
        response to a getStatus() query.
    **running** (bool or None)
        Whether the job is running.  Only set by handleStatusRes() in
        response to a getStatus() query.
    **client_connection** :py:class:`Connection`
        The client connection associated with the job.
    **worker_connection** (:py:class:`Connection` or None)
        The worker connection associated with the job.  Only set after the job
        has been assigned to a worker.
    """

    def __init__(self, handle, name, arguments, client_connection,
                 unique=None):
        super(ServerJob, self).__init__(name, arguments, unique)
        self.handle = handle
        self.client_connection = client_connection
        self.worker_connection = None
        del self.connection


class ServerAdminRequest(AdminRequest):
    """An administrative request sent to a server."""

    def __init__(self, connection):
        super(ServerAdminRequest, self).__init__()
        self.connection = connection

    def isComplete(self, data):
        if data[-1:] == b'\n':
            self.command = data.strip()
            return True
        return False


class ServerConnection(Connection):
    """A Connection to a Gearman Client."""

    def __init__(self, addr, conn, use_ssl, client_id):
        if client_id:
            self.log = logging.getLogger("gear.ServerConnection.%s" %
                                         (client_id,))
        else:
            self.log = logging.getLogger("gear.ServerConnection")
        self.host = addr[0]
        self.port = addr[1]
        self.conn = conn
        self.use_ssl = use_ssl
        self.client_id = None
        self.functions = set()
        self.related_jobs = {}
        self.ssl_subject = None
        if self.use_ssl:
            for x in conn.getpeercert()['subject']:
                if x[0][0] == 'commonName':
                    self.ssl_subject = x[0][1]
            self.log.debug("SSL subject: %s" % self.ssl_subject)
        self.changeState("INIT")

    def _getAdminRequest(self):
        return ServerAdminRequest(self)

    def __repr__(self):
        return '<gear.ServerConnection 0x%x name: %s host: %s port: %s>' % (
            id(self), self.client_id, self.host, self.port)


class Server(BaseClientServer):
    """A simple gearman server implementation for testing
    (not for production use).

    :arg int port: The TCP port on which to listen.
    :arg str ssl_key: Path to the SSL private key.
    :arg str ssl_cert: Path to the SSL certificate.
    :arg str ssl_ca: Path to the CA certificate.
    :arg str statsd_host: statsd hostname.  None means disabled
        (the default).
    :arg str statsd_port: statsd port (defaults to 8125).
    :arg str statsd_prefix: statsd key prefix.
    :arg str client_id: The ID associated with this server.
        It will be appending to the name of the logger (e.g.,
        gear.Server.server_id).  Defaults to None (unused).
    :arg ACL acl: An :py:class:`ACL` object if the server should apply
        access control rules to its connections.
    """

    def __init__(self, port=4730, ssl_key=None, ssl_cert=None, ssl_ca=None,
                 statsd_host=None, statsd_port=8125, statsd_prefix=None,
                 server_id=None, acl=None):
        self.port = port
        self.ssl_key = ssl_key
        self.ssl_cert = ssl_cert
        self.ssl_ca = ssl_ca
        self.high_queue = []
        self.normal_queue = []
        self.low_queue = []
        self.jobs = {}
        self.functions = set()
        self.max_handle = 0
        self.acl = acl
        self.connect_wake_read, self.connect_wake_write = os.pipe()

        self.use_ssl = False
        if all([self.ssl_key, self.ssl_cert, self.ssl_ca]):
            self.use_ssl = True

        for res in socket.getaddrinfo(None, self.port, socket.AF_UNSPEC,
                                      socket.SOCK_STREAM, 0,
                                      socket.AI_PASSIVE):
            af, socktype, proto, canonname, sa = res
            try:
                self.socket = socket.socket(af, socktype, proto)
                self.socket.setsockopt(socket.SOL_SOCKET,
                                       socket.SO_REUSEADDR, 1)
            except socket.error:
                self.socket = None
                continue
            try:
                self.socket.bind(sa)
                self.socket.listen(1)
            except socket.error:
                self.socket.close()
                self.socket = None
                continue
            break

        if self.socket is None:
            raise Exception("Could not open socket")

        if port == 0:
            self.port = self.socket.getsockname()[1]

        super(Server, self).__init__(server_id)
        if server_id:
            self.log = logging.getLogger("gear.Server.%s" % (self.client_id,))
        else:
            self.log = logging.getLogger("gear.Server")

        if statsd_host:
            if not statsd:
                self.log.error("Unable to import statsd module")
                self.statsd = None
            else:
                self.statsd = statsd.StatsClient(statsd_host,
                                                 statsd_port,
                                                 statsd_prefix)
        else:
            self.statsd = None

    def _doConnectLoop(self):
        while self.running:
            try:
                self.connectLoop()
            except Exception:
                self.log.exception("Exception in connect loop:")
                time.sleep(1)

    def connectLoop(self):
        poll = select.poll()
        bitmask = (select.POLLIN | select.POLLERR |
                   select.POLLHUP | select.POLLNVAL)
        # Register the wake pipe so that we can break if we need to
        # shutdown.
        poll.register(self.connect_wake_read, bitmask)
        poll.register(self.socket.fileno(), bitmask)
        while self.running:
            ret = poll.poll()
            for fd, event in ret:
                if fd == self.connect_wake_read:
                    self.log.debug("Accept woken by pipe")
                    while True:
                        if os.read(self.connect_wake_read, 1) == b'\n':
                            break
                    return
                if event & select.POLLIN:
                    self.log.debug("Accepting new connection")
                    c, addr = self.socket.accept()
                    if self.use_ssl:
                        c = ssl.wrap_socket(c, server_side=True,
                                            keyfile=self.ssl_key,
                                            certfile=self.ssl_cert,
                                            ca_certs=self.ssl_ca,
                                            cert_reqs=ssl.CERT_REQUIRED,
                                            ssl_version=ssl.PROTOCOL_TLSv1)
                    conn = ServerConnection(addr, c, self.use_ssl,
                                            self.client_id)
                    self.log.info("Accepted connection %s" % (conn,))
                    self.connections_condition.acquire()
                    try:
                        self.active_connections.append(conn)
                        self.connections_condition.notifyAll()
                        os.write(self.wake_write, b'1\n')
                    finally:
                        self.connections_condition.release()

    def _shutdown(self):
        super(Server, self)._shutdown()
        os.write(self.connect_wake_write, b'1\n')

    def _cleanup(self):
        super(Server, self)._cleanup()
        self.socket.close()
        os.close(self.connect_wake_read)
        os.close(self.connect_wake_write)

    def _lostConnection(self, conn):
        # Called as soon as a connection is detected as faulty.
        self.log.info("Marking %s as disconnected" % conn)
        self.connections_condition.acquire()
        try:
            jobs = conn.related_jobs.values()
            if conn in self.active_connections:
                self.active_connections.remove(conn)
        finally:
            self.connections_condition.notifyAll()
            self.connections_condition.release()
        for job in jobs:
            if job.worker_connection == conn:
                # the worker disconnected, alert the client
                try:
                    p = Packet(constants.REQ, constants.WORK_FAIL, job.handle)
                    job.client_connection.sendPacket(p)
                except Exception:
                    self.log.exception("Sending WORK_FAIL to client after "
                                       "worker disconnect failed:")
            self._removeJob(job)
        self._updateStats()

    def _removeJob(self, job, dequeue=True):
        # dequeue is tri-state: True, False, or a specific queue
        try:
            del job.client_connection.related_jobs[job.handle]
        except KeyError:
            pass
        if job.worker_connection:
            try:
                del job.worker_connection.related_jobs[job.handle]
            except KeyError:
                pass
        try:
            del self.jobs[job.handle]
        except KeyError:
            pass
        if dequeue is True:
            # Search all queues for the job
            try:
                self.high_queue.remove(job)
            except ValueError:
                pass
            try:
                self.normal_queue.remove(job)
            except ValueError:
                pass
            try:
                self.low_queue.remove(job)
            except ValueError:
                pass
        elif dequeue is not False:
            # A specific queue was supplied
            dequeue.remove(job)
        # If dequeue is false, no need to remove from any queue

    def getQueue(self):
        """Returns a copy of all internal queues in a flattened form.

        :returns: The Gearman queue.
        :rtype: list of :py:class:`WorkerJob`.
        """
        ret = []
        for queue in [self.high_queue, self.normal_queue, self.low_queue]:
            ret += queue
        return ret

    def handleAdminRequest(self, request):
        if request.command.startswith(b'cancel job'):
            self.handleCancelJob(request)
        elif request.command.startswith(b'status'):
            self.handleStatus(request)
        elif request.command.startswith(b'workers'):
            self.handleWorkers(request)
        elif request.command.startswith(b'acl list'):
            self.handleACLList(request)
        elif request.command.startswith(b'acl grant'):
            self.handleACLGrant(request)
        elif request.command.startswith(b'acl revoke'):
            self.handleACLRevoke(request)
        elif request.command.startswith(b'acl self-revoke'):
            self.handleACLSelfRevoke(request)

    def _cancelJob(self, request, job, queue):
        if self.acl:
            if not self.acl.canInvoke(request.connection.ssl_subject,
                                      job.name):
                self.log.info("Rejecting cancel job from %s for %s "
                              "due to ACL" %
                              (request.connection.ssl_subject, job.name))
                request.connection.sendRaw(b'ERR PERMISSION_DENIED\n')
                return
        self._removeJob(job, dequeue=queue)
        self._updateStats()
        request.connection.sendRaw(b'OK\n')
        return

    def handleCancelJob(self, request):
        words = request.command.split()
        handle = words[2]

        if handle in self.jobs:
            for queue in [self.high_queue, self.normal_queue, self.low_queue]:
                for job in queue:
                    if handle == job.handle:
                        return self._cancelJob(request, job, queue)
        request.connection.sendRaw(b'ERR UNKNOWN_JOB\n')

    def handleACLList(self, request):
        if self.acl is None:
            request.connection.sendRaw(b'ERR ACL_DISABLED\n')
            return
        for entry in self.acl.getEntries():
            l = "%s\tregister=%s\tinvoke=%s\tgrant=%s\n" % (
                entry.subject, entry.register, entry.invoke, entry.grant)
            request.connection.sendRaw(l.encode('utf8'))
        request.connection.sendRaw(b'.\n')

    def handleACLGrant(self, request):
        # acl grant register worker .*
        words = request.command.split(None, 4)
        verb = words[2]
        subject = words[3]

        if self.acl is None:
            request.connection.sendRaw(b'ERR ACL_DISABLED\n')
            return
        if not self.acl.canGrant(request.connection.ssl_subject):
            request.connection.sendRaw(b'ERR PERMISSION_DENIED\n')
            return
        try:
            if verb == 'invoke':
                self.acl.grantInvoke(subject, words[4])
            elif verb == 'register':
                self.acl.grantRegister(subject, words[4])
            elif verb == 'grant':
                self.acl.grantGrant(subject)
            else:
                request.connection.sendRaw(b'ERR UNKNOWN_ACL_VERB\n')
                return
        except ACLError, e:
            self.log.info("Error in grant command: %s" % (e.message,))
            request.connection.sendRaw(b'ERR UNABLE %s\n' % (e.message,))
            return
        request.connection.sendRaw(b'OK\n')

    def handleACLRevoke(self, request):
        # acl revoke register worker
        words = request.command.split()
        verb = words[2]
        subject = words[3]

        if self.acl is None:
            request.connection.sendRaw(b'ERR ACL_DISABLED\n')
            return
        if subject != request.connection.ssl_subject:
            if not self.acl.canGrant(request.connection.ssl_subject):
                request.connection.sendRaw(b'ERR PERMISSION_DENIED\n')
                return
        try:
            if verb == 'invoke':
                self.acl.revokeInvoke(subject)
            elif verb == 'register':
                self.acl.revokeRegister(subject)
            elif verb == 'grant':
                self.acl.revokeGrant(subject)
            elif verb == 'all':
                try:
                    self.acl.remove(subject)
                except ACLError:
                    pass
            else:
                request.connection.sendRaw(b'ERR UNKNOWN_ACL_VERB\n')
                return
        except ACLError, e:
            self.log.info("Error in revoke command: %s" % (e.message,))
            request.connection.sendRaw(b'ERR UNABLE %s\n' % (e.message,))
            return
        request.connection.sendRaw(b'OK\n')

    def handleACLSelfRevoke(self, request):
        # acl self-revoke register
        words = request.command.split()
        verb = words[2]

        if self.acl is None:
            request.connection.sendRaw(b'ERR ACL_DISABLED\n')
            return
        subject = request.connection.ssl_subject
        try:
            if verb == 'invoke':
                self.acl.revokeInvoke(subject)
            elif verb == 'register':
                self.acl.revokeRegister(subject)
            elif verb == 'grant':
                self.acl.revokeGrant(subject)
            elif verb == 'all':
                try:
                    self.acl.remove(subject)
                except ACLError:
                    pass
            else:
                request.connection.sendRaw(b'ERR UNKNOWN_ACL_VERB\n')
                return
        except ACLError, e:
            self.log.info("Error in self-revoke command: %s" % (e.message,))
            request.connection.sendRaw(b'ERR UNABLE %s\n' % (e.message,))
            return
        request.connection.sendRaw(b'OK\n')

    def _getFunctionStats(self):
        functions = {}
        for function in self.functions:
            # Total, running, workers
            functions[function] = [0, 0, 0]
        for job in self.jobs.values():
            if job.name not in functions:
                functions[job.name] = [0, 0, 0]
            functions[job.name][0] += 1
            if job.running:
                functions[job.name][1] += 1
        for connection in self.active_connections:
            for function in connection.functions:
                if function not in functions:
                    functions[function] = [0, 0, 0]
                functions[function][2] += 1
        return functions

    def handleStatus(self, request):
        functions = self._getFunctionStats()
        for name, values in functions.items():
            request.connection.sendRaw(("%s\t%s\t%s\t%s\n" %
                                       (name, values[0], values[1],
                                        values[2])).encode('utf8'))
        request.connection.sendRaw(b'.\n')

    def handleWorkers(self, request):
        for connection in self.active_connections:
            fd = connection.conn.fileno()
            ip = connection.host
            client_id = connection.client_id or '-'
            functions = ' '.join(connection.functions)
            request.connection.sendRaw(("%s %s %s : %s\n" %
                                       (fd, ip, client_id, functions))
                                       .encode('utf8'))
        request.connection.sendRaw(b'.\n')

    def wakeConnections(self):
        p = Packet(constants.RES, constants.NOOP, b'')
        for connection in self.active_connections:
            if connection.state == 'SLEEP':
                connection.changeState("AWAKE")
                connection.sendPacket(p)

    def reportTimingStats(self, ptype, duration):
        """Report processing times by packet type

        This method is called by handlePacket to report how long
        processing took for each packet.  If statsd is configured,
        timing and counts are reported with the key
        "prefix.packet.NAME".

        :arg bytes ptype: The packet type (one of the packet types in
            constants).
        :arg float duration: The time (in seconds) it took to process
            the packet.
        """
        if not self.statsd:
            return
        ptype = constants.types.get(ptype, 'UNKNOWN')
        key = 'packet.%s' % ptype
        self.statsd.timing(key, int(duration * 1000))
        self.statsd.incr(key)

    def _updateStats(self):
        if not self.statsd:
            return

        # prefix.queue.total
        # prefix.queue.running
        # prefix.queue.waiting
        # prefix.workers
        base_key = 'queue'
        total = 0
        running = 0
        waiting = 0
        for job in self.jobs.values():
            total += 1
            if job.running:
                running += 1
            else:
                waiting += 1

        key = '.'.join([base_key, 'total'])
        self.statsd.gauge(key, total)

        key = '.'.join([base_key, 'running'])
        self.statsd.gauge(key, running)

        key = '.'.join([base_key, 'waiting'])
        self.statsd.gauge(key, waiting)

        workers = 0
        for connection in self.active_connections:
            if connection.functions:
                workers += 1
        self.statsd.gauge('workers', workers)

    def _handleSubmitJob(self, packet, precedence):
        name = packet.getArgument(0)
        unique = packet.getArgument(1)
        if not unique:
            unique = None
        arguments = packet.getArgument(2, True)
        if self.acl:
            if not self.acl.canInvoke(packet.connection.ssl_subject, name):
                self.log.info("Rejecting SUBMIT_JOB from %s for %s "
                              "due to ACL" %
                              (packet.connection.ssl_subject, name))
                self.sendError(packet.connection, 0,
                               'Permission denied by ACL')
                return
        self.max_handle += 1
        handle = ('H:%s:%s' % (packet.connection.host,
                               self.max_handle)).encode('utf8')
        job = ServerJob(handle, name, arguments, packet.connection, unique)
        p = Packet(constants.RES, constants.JOB_CREATED, handle)
        packet.connection.sendPacket(p)
        self.jobs[handle] = job
        packet.connection.related_jobs[handle] = job
        if precedence == PRECEDENCE_HIGH:
            self.high_queue.append(job)
        elif precedence == PRECEDENCE_NORMAL:
            self.normal_queue.append(job)
        elif precedence == PRECEDENCE_LOW:
            self.low_queue.append(job)
        self._updateStats()
        self.wakeConnections()

    def handleSubmitJob(self, packet):
        return self._handleSubmitJob(packet, PRECEDENCE_NORMAL)

    def handleSubmitJobHigh(self, packet):
        return self._handleSubmitJob(packet, PRECEDENCE_HIGH)

    def handleSubmitJobLow(self, packet):
        return self._handleSubmitJob(packet, PRECEDENCE_LOW)

    def getJobForConnection(self, connection, peek=False):
        for queue in [self.high_queue, self.normal_queue, self.low_queue]:
            for job in queue:
                if job.name in connection.functions:
                    if not peek:
                        queue.remove(job)
                        connection.related_jobs[job.handle] = job
                        job.worker_connection = connection
                    job.running = True
                    self._updateStats()
                    return job
        return None

    def handleGrabJobUniq(self, packet):
        job = self.getJobForConnection(packet.connection)
        if job:
            self.sendJobAssignUniq(packet.connection, job)
        else:
            self.sendNoJob(packet.connection)

    def sendJobAssignUniq(self, connection, job):
        unique = job.unique
        if not unique:
            unique = b''
        data = b'\x00'.join((job.handle, job.name, unique, job.arguments))
        p = Packet(constants.RES, constants.JOB_ASSIGN_UNIQ, data)
        connection.sendPacket(p)

    def sendNoJob(self, connection):
        p = Packet(constants.RES, constants.NO_JOB, b'')
        connection.sendPacket(p)

    def handlePreSleep(self, packet):
        packet.connection.changeState("SLEEP")
        if self.getJobForConnection(packet.connection, peek=True):
            self.wakeConnections()

    def handleWorkComplete(self, packet):
        self.handlePassthrough(packet, True)

    def handleWorkFail(self, packet):
        self.handlePassthrough(packet, True)

    def handleWorkException(self, packet):
        self.handlePassthrough(packet, True)

    def handleWorkData(self, packet):
        self.handlePassthrough(packet)

    def handleWorkWarning(self, packet):
        self.handlePassthrough(packet)

    def handleWorkStatus(self, packet):
        handle = packet.getArgument(0)
        job = self.jobs.get(handle)
        if not job:
            raise UnknownJobError()
        job.numerator = packet.getArgument(1)
        job.denominator = packet.getArgument(2)
        self.handlePassthrough(packet)

    def handlePassthrough(self, packet, finished=False):
        handle = packet.getArgument(0)
        job = self.jobs.get(handle)
        if not job:
            raise UnknownJobError()
        packet.code = constants.RES
        job.client_connection.sendPacket(packet)
        if finished:
            self._removeJob(job, dequeue=False)
            self._updateStats()

    def handleSetClientID(self, packet):
        name = packet.getArgument(0)
        packet.connection.client_id = name

    def sendError(self, connection, code, text):
        data = (str(code).encode('utf8') + b'\x00' +
                str(text).encode('utf8') + b'\x00')
        p = Packet(constants.RES, constants.ERROR, data)
        connection.sendPacket(p)

    def handleCanDo(self, packet):
        name = packet.getArgument(0)
        if self.acl:
            if not self.acl.canRegister(packet.connection.ssl_subject, name):
                self.log.info("Ignoring CAN_DO from %s for %s due to ACL" %
                              (packet.connection.ssl_subject, name))
                # CAN_DO normally does not merit a response so it is
                # not clear that it is appropriate to send an ERROR
                # response at this point.
                return
        self.log.debug("Adding function %s to %s" % (name, packet.connection))
        packet.connection.functions.add(name)
        self.functions.add(name)

    def handleCantDo(self, packet):
        name = packet.getArgument(0)
        self.log.debug("Removing function %s from %s" %
                       (name, packet.connection))
        packet.connection.functions.remove(name)

    def handleResetAbilities(self, packet):
        self.log.debug("Resetting functions for %s" % packet.connection)
        packet.connection.functions = set()

    def handleGetStatus(self, packet):
        handle = packet.getArgument(0)
        self.log.debug("Getting status for %s" % handle)

        known = 0
        running = 0
        numerator = b''
        denominator = b''
        job = self.jobs.get(handle)
        if job:
            known = 1
            if job.running:
                running = 1
            numerator = job.numerator or b''
            denominator = job.denominator or b''

        data = (handle + b'\x00' +
                str(known).encode('utf8') + b'\x00' +
                str(running).encode('utf8') + b'\x00' +
                numerator + b'\x00' +
                denominator)
        p = Packet(constants.RES, constants.STATUS_RES, data)
        packet.connection.sendPacket(p)
