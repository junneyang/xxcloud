# Copyright 2014 OpenStack Foundation
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

import re


class ACLError(Exception):
    pass


class ACLEntry(object):
    """An access control list entry.

    :arg str subject: The SSL certificate Subject Common Name to which
        the entry applies.

    :arg str register: A regular expression that matches the jobs that
        connections with this certificate are permitted to register.

    :arg str invoke: A regular expression that matches the jobs that
        connections with this certificate are permitted to invoke.
        Also implies the permission to cancel the same set of jobs in
        the queue.

    :arg boolean grant: A flag indicating whether connections with
        this certificate are permitted to grant access to other
        connections.  Also implies the permission to revoke access
        from other connections.  The ability to self-revoke access is
        always implied.
    """

    def __init__(self, subject, register=None, invoke=None, grant=False):
        self.subject = subject
        self.setRegister(register)
        self.setInvoke(invoke)
        self.setGrant(grant)

    def __repr__(self):
        return ('<ACLEntry for %s register=%s invoke=%s grant=%s>' %
                (self.subject, self.register, self.invoke, self.grant))

    def isEmpty(self):
        """Checks whether this entry grants any permissions at all.

        :returns: False if any permission is granted, otherwise True.
        """
        if (self.register is None and
            self.invoke is None and
            self.grant is False):
            return True
        return False

    def canRegister(self, name):
        """Check whether this subject is permitted to register a function.

        :arg str name: The function name to check.
        :returns: A boolean indicating whether the action should be permitted.
        """
        if self.register is None:
            return False
        if not self._register.match(name):
            return False
        return True

    def canInvoke(self, name):
        """Check whether this subject is permitted to register a function.

        :arg str name: The function name to check.
        :returns: A boolean indicating whether the action should be permitted.
        """
        if self.invoke is None:
            return False
        if not self._invoke.match(name):
            return False
        return True

    def setRegister(self, register):
        """Sets the functions that this subject can register.

        :arg str register: A regular expression that matches the jobs that
           connections with this certificate are permitted to register.
        """
        self.register = register
        if register:
            try:
                self._register = re.compile(register)
            except re.error, e:
                raise ACLError('Regular expression error: %s' % (e.message,))
        else:
            self._register = None

    def setInvoke(self, invoke):
        """Sets the functions that this subject can invoke.

        :arg str invoke: A regular expression that matches the jobs that
           connections with this certificate are permitted to invoke.
        """
        self.invoke = invoke
        if invoke:
            try:
                self._invoke = re.compile(invoke)
            except re.error, e:
                raise ACLError('Regular expression error: %s' % (e.message,))
        else:
            self._invoke = None

    def setGrant(self, grant):
        """Sets whether this subject can grant ACLs to others.

        :arg boolean grant: A flag indicating whether connections with
            this certificate are permitted to grant access to other
            connections.  Also implies the permission to revoke access
            from other connections.  The ability to self-revoke access is
            always implied.
        """
        self.grant = grant


class ACL(object):
    """An access control list.

    ACLs are deny-by-default.  The checked actions are only allowed if
    there is an explicit rule in the ACL granting permission for a
    given client (identified by SSL certificate Common Name Subject)
    to perform that action.
    """

    def __init__(self):
        self.subjects = {}

    def add(self, entry):
        """Add an ACL entry.

        :arg Entry entry: The :py:class:`ACLEntry` to add.
        :raises ACLError: If there is already an entry for the subject.
        """
        if entry.subject in self.subjects:
            raise ACLError("An ACL entry for %s already exists" %
                           (entry.subject,))
        self.subjects[entry.subject] = entry

    def remove(self, subject):
        """Remove an ACL entry.

        :arg str subject: The SSL certificate Subject Common Name to
            remove from the ACL.
        :raises ACLError: If there is no entry for the subject.
        """
        if subject not in self.subjects:
            raise ACLError("There is no ACL entry for %s" % (subject,))
        del self.subjects[subject]

    def getEntries(self):
        """Return a list of current ACL entries.

        :returns: A list of :py:class:`ACLEntry` objects.
        """
        items = self.subjects.items()
        items.sort(lambda a, b: cmp(a[0], b[0]))
        return [x[1] for x in items]

    def canRegister(self, subject, name):
        """Check whether a subject is permitted to register a function.

        :arg str subject: The SSL certificate Subject Common Name to
            check against.
        :arg str name: The function name to check.
        :returns: A boolean indicating whether the action should be permitted.
        """
        entry = self.subjects.get(subject)
        if entry is None:
            return False
        return entry.canRegister(name)

    def canInvoke(self, subject, name):
        """Check whether a subject is permitted to invoke a function.

        :arg str subject: The SSL certificate Subject Common Name to
            check against.
        :arg str name: The function name to check.
        :returns: A boolean indicating whether the action should be permitted.
        """
        entry = self.subjects.get(subject)
        if entry is None:
            return False
        return entry.canInvoke(name)

    def canGrant(self, subject):
        """Check whether a subject is permitted to grant access to others.

        :arg str subject: The SSL certificate Subject Common Name to
            check against.
        :returns: A boolean indicating whether the action should be permitted.
        """
        entry = self.subjects.get(subject)
        if entry is None:
            return False
        if not entry.grant:
            return False
        return True

    def grantInvoke(self, subject, invoke):
        """Grant permission to invoke certain functions.

        :arg str subject: The SSL certificate Subject Common Name to which
            the entry applies.
        :arg str invoke: A regular expression that matches the jobs
            that connections with this certificate are permitted to
            invoke.  Also implies the permission to cancel the same
            set of jobs in the queue.
        """
        e = self.subjects.get(subject)
        if not e:
            e = ACLEntry(subject)
            self.add(e)
        e.setInvoke(invoke)

    def grantRegister(self, subject, register):
        """Grant permission to register certain functions.

        :arg str subject: The SSL certificate Subject Common Name to which
            the entry applies.
        :arg str register: A regular expression that matches the jobs that
            connections with this certificate are permitted to register.
        """
        e = self.subjects.get(subject)
        if not e:
            e = ACLEntry(subject)
            self.add(e)
        e.setRegister(register)

    def grantGrant(self, subject):
        """Grant permission to grant permissions to other connections.

        :arg str subject: The SSL certificate Subject Common Name to which
            the entry applies.
        """
        e = self.subjects.get(subject)
        if not e:
            e = ACLEntry(subject)
            self.add(e)
        e.setGrant(True)

    def revokeInvoke(self, subject):
        """Revoke permission to invoke all functions.

        :arg str subject: The SSL certificate Subject Common Name to which
            the entry applies.
        """
        e = self.subjects.get(subject)
        if e:
            e.setInvoke(None)
            if e.isEmpty():
                self.remove(subject)

    def revokeRegister(self, subject):
        """Revoke permission to register all functions.

        :arg str subject: The SSL certificate Subject Common Name to which
            the entry applies.
        """
        e = self.subjects.get(subject)
        if e:
            e.setRegister(None)
            if e.isEmpty():
                self.remove(subject)

    def revokeGrant(self, subject):
        """Revoke permission to grant permissions to other connections.

        :arg str subject: The SSL certificate Subject Common Name to which
            the entry applies.
        """
        e = self.subjects.get(subject)
        if e:
            e.setGrant(False)
            if e.isEmpty():
                self.remove(subject)
