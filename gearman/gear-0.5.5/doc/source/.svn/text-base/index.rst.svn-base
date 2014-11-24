Gear: Asynchronous Event-Driven Gearman Interface
=================================================
.. module:: gear
   :synopsis: Asynchronous Event-Driven Gearman Interface

This module implements an asynchronous event-driven interface to
Gearman.  It provides interfaces to build a client or worker, and
access to the administrative protocol.  The design approach is to keep
it simple, with a relatively thin abstration of the Gearman protocol
itself.  It should be easy to use to build a client or worker that
operates either synchronously or asynchronously.

The module also provides a simple Gearman server for use as a
convenience in unit tests.  The server is not designed for production
use under load.

Client Example
--------------

To use the client interface, instantiate a
:py:class:`Client`, and submit a :py:class:`Job`.  For example::

    import gear
    client = gear.Client()
    client.addServer('gearman.example.com')
    client.waitForServer()  # Wait for at least one server to be connected

    job = gear.Job("reverse", "test string")
    client.submitJob(job)

The waitForServer() call is only necessary when running in a
synchronous context.  When running asynchronously, it is probably more
desirable to omit that call and instead handle the
:py:class:`NoConnectedServersError` exception that submitJob may
raise if no servers are connected at the time.

When Gearman returns data to the client, the :py:class:`Job` object is
updated immediately.  Event handlers are called on the
:py:class:`Client` object so that subclasses have ample facilities for
reacting to events synchronously.

Worker Example
--------------

To use the worker interface, create a :py:class:`Worker`, register at
least one function that the worker supports, and then wait for a Job
to be dispatched to the worker.

An example of a Gearman worker::

    import gear
    worker = gear.Worker('reverser')
    worker.addServer('gearman.example.com')
    worker.registerFunction("reverse")

    while True:
        job = worker.getJob()
        job.sendWorkComplete(job.arguments[::-1])

SSL Connections
---------------

For versions of Gearman supporting SSL connections, specify the
files containing the SSL private key, public certificate, and
CA certificate in the addServer() call. For example::

     ssl_key = '/path/to/key.pem'
     ssl_cert = '/path/to/cert.pem'
     ssl_ca = '/path/to/ca.pem'
     client.addServer('gearman.example.com', 4730, ssl_key, ssl_cert, ssl_ca)

All three files must be specified for SSL to be used.

API Reference
=============

The following sections document the module's public API.  It is
divided into sections focusing on implementing a client, a worker,
using the administrative protocol, and then the classes that are
common to all usages of the module.

Client Usage
------------

The classes in this section should be all that are needed in order to
implement a Gearman client.

Client Objects
^^^^^^^^^^^^^^
.. autoclass:: gear.Client
  :members:
  :inherited-members:

Job Objects
^^^^^^^^^^^
.. autoclass:: gear.Job
  :members:
  :inherited-members:


Worker Usage
------------

The classes in this section should be all that are needed in order to
implement a Gearman worker.

Worker Objects
^^^^^^^^^^^^^^
.. autoclass:: gear.Worker
  :members:
  :inherited-members:

FunctionRecord Objects
^^^^^^^^^^^^^^^^^^^^^^
.. autoclass:: gear.FunctionRecord
  :members:
  :inherited-members:

WorkerJob Objects
^^^^^^^^^^^^^^^^^
.. autoclass:: gear.WorkerJob
  :members:
  :inherited-members:

Administrative Protocol
-----------------------

Gearman provides an administrative protocol that is multiplexed on the
same connection as the normal binary protocol for jobs.  The classes
in this section are useful for working with that protocol.  They need
to be used with an existing :py:class:`Connection` object; either one
obtained via a :py:class:`Client` or :py:class:`Worker`, or via direct
instantiation of :py:class:`Connection` to a Gearman server.

AdminRequest Objects
^^^^^^^^^^^^^^^^^^^^
.. autoclass:: gear.AdminRequest
  :members:
  :inherited-members:

.. autoclass:: gear.StatusAdminRequest
  :inherited-members:

.. autoclass:: gear.ShowJobsAdminRequest
  :inherited-members:

.. autoclass:: gear.ShowUniqueJobsAdminRequest
  :inherited-members:

.. autoclass:: gear.CancelJobAdminRequest
  :inherited-members:

.. autoclass:: gear.VersionAdminRequest
  :inherited-members:


Server Usage
------------
.. program-output:: geard --help

The syntax of the optional ACL file consists of a number of sections
identified by the SSL certificate Common Name Subject, and the
arguments to the :py:class:`ACLEntry` constructor as key-value pairs::

  [<subject>]
  register=<regex>
  invoke=<regex>
  grant=<boolean>

For example::

  [my_worker]
  register=.*

  [my_client]
  invoke=.*

  [my_node_manager]
  grant=True

Server Objects
^^^^^^^^^^^^^^
.. autoclass:: gear.Server
  :members:
  :inherited-members:


Access Control
--------------

The gear server supports authorization via access control lists.  When
an :py:class:`ACL` object is supplied to the server (or a file on the
command line), gear changes from the normal Gearman mode of
allow-by-default to deny-by-default and only clients with ACL entries
will be able to perform actions such as registering functions or
submitting jobs.  Authorization is based on the SSL certificate Common
Name Subject associated with the connection.  An :py:class:`ACL`
object may be modified programatically at run-time.

The administrative protocol supports modifying ACLs with the following
commands:

**acl list**
  List the current acls::

    acl list
    client	register=None	invoke=.*	grant=True
    worker	register=.*	invoke=None	grant=True
    .

**acl grant <verb> <subject> <pattern>**
  Grant the `<verb>` action for functions matching `<pattern>` to
  `<subject>`.  Verbs can be one of ``register``, ``invoke``, or
  ``grant``.  This requires the current connection have the grant
  permission.  Example::

    acl grant register worker .*
    OK

**acl revoke <verb> <subject>**
  Revoke the `<verb>` action from `<subject>`.  Verbs can be one of
  ``register``, ``invoke``, ``grant``, or ``all`` to indicate all
  permissions for the subject should be revoked.  This requires the
  grant permission, except that a subject may always revoke its own
  permissions.  Example::

    acl revoke register worker
    OK

**acl self-revoke <verb>**
  Revoke the `<verb>` action from connections associted with the
  current certificate subject.  Verbs can be one of ``register``,
  ``invoke``, ``grant``, or ``all`` to indicate all permissions for
  the subject should be revoked.  This is similar to ``acl revoke``
  but is a convenience method so that a subject does not need to know
  its own common name.  A subject always has permission to revoke its
  own permissions.  Example::

    acl self-revoke register
    OK

ACL Objects
^^^^^^^^^^^
.. autoclass:: gear.ACL
  :members:
  :inherited-members:

ACLEntry Objects
^^^^^^^^^^^^^^^^
.. autoclass:: gear.ACLEntry
  :members:
  :inherited-members:


Common
------

These classes do not normally need to be directly instatiated to use
the gear API, but they may be returned or otherwise be accessible from
other classes in this module.  They generally operate at a lower
level, but still form part of the public API.

Connection Objects
^^^^^^^^^^^^^^^^^^
.. autoclass:: gear.Connection
  :members:
  :inherited-members:

Packet Objects
^^^^^^^^^^^^^^
.. autoclass:: gear.Packet
  :members:
  :inherited-members:

Exceptions
^^^^^^^^^^
.. autoexception:: gear.ConnectionError
.. autoexception:: gear.InvalidDataError
.. autoexception:: gear.ConfigurationError
.. autoexception:: gear.NoConnectedServersError
.. autoexception:: gear.UnknownJobError
.. autoexception:: gear.InterruptedError


Constants
---------

These constants are used by public API classes.

.. py:data:: PRECEDENCE_NORMAL

   Normal job precedence.

.. py:data:: PRECEDENCE_LOW

   Low job precedence.

.. py:data:: PRECEDENCE_HIGH

   High job precedence.

.. automodule:: gear.constants
  :members:


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

