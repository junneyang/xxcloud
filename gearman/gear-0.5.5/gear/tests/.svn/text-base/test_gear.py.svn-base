# Copyright (c) 2013 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import testscenarios

import gear
from gear import tests


class ConnectionTestCase(tests.BaseTestCase):

    scenarios = [
        ('both_string',
         dict(host="hostname", port='80')),
        ('string_int',
         dict(host="hostname", port=80)),
        ('none_string',
         dict(host=None, port="80")),
    ]

    def setUp(self):
        super(ConnectionTestCase, self).setUp()
        self.conn = gear.Connection(self.host, self.port)

    def test_params(self):
        self.assertTrue(repr(self.conn).endswith(
            'host: %s port: %s>' % (self.host, self.port)))


class TestClient(tests.BaseTestCase):

    def test_handleStatusRes_1(self):
        client = gear.Client()

        packet = gear.Packet(
            gear.constants.RES,
            gear.constants.STATUS_RES,
            b'H:127.0.0.1:11\x001\x001\x00\x00'
        )
        packet.getJob = lambda: gear.Job("", "")
        job = client.handleStatusRes(packet)

        self.assertTrue(job.known)
        self.assertTrue(job.running)

    def test_handleStatusRes_2(self):
        client = gear.Client()

        packet = gear.Packet(
            gear.constants.RES,
            gear.constants.STATUS_RES,
            b'H:127.0.0.1:11\x001\x000\x00\x00'
        )
        packet.getJob = lambda: gear.Job("", "")
        job = client.handleStatusRes(packet)

        self.assertTrue(job.known)
        self.assertFalse(job.running)

    def test_ACL(self):
        acl = gear.ACL()
        acl.add(gear.ACLEntry('worker', register='foo.*'))
        acl.add(gear.ACLEntry('client', invoke='foo.*'))
        acl.add(gear.ACLEntry('manager', grant=True))
        self.assertEqual(len(acl.getEntries()), 3)

        self.assertTrue(acl.canRegister('worker', 'foo-bar'))
        self.assertTrue(acl.canRegister('worker', 'foo'))
        self.assertFalse(acl.canRegister('worker', 'bar-foo'))
        self.assertFalse(acl.canRegister('worker', 'bar'))
        self.assertFalse(acl.canInvoke('worker', 'foo'))
        self.assertFalse(acl.canGrant('worker'))

        self.assertTrue(acl.canInvoke('client', 'foo-bar'))
        self.assertTrue(acl.canInvoke('client', 'foo'))
        self.assertFalse(acl.canInvoke('client', 'bar-foo'))
        self.assertFalse(acl.canInvoke('client', 'bar'))
        self.assertFalse(acl.canRegister('client', 'foo'))
        self.assertFalse(acl.canGrant('client'))

        self.assertFalse(acl.canInvoke('manager', 'bar'))
        self.assertFalse(acl.canRegister('manager', 'foo'))
        self.assertTrue(acl.canGrant('manager'))

        acl.remove('worker')
        acl.remove('client')
        acl.remove('manager')

        self.assertFalse(acl.canRegister('worker', 'foo'))
        self.assertFalse(acl.canInvoke('client', 'foo'))
        self.assertFalse(acl.canGrant('manager'))

        self.assertEqual(len(acl.getEntries()), 0)

    def test_ACL_register(self):
        acl = gear.ACL()
        acl.grantRegister('worker', 'bar.*')
        self.assertTrue(acl.canRegister('worker', 'bar'))
        acl.revokeRegister('worker')
        self.assertFalse(acl.canRegister('worker', 'bar'))

    def test_ACL_invoke(self):
        acl = gear.ACL()
        acl.grantInvoke('client', 'bar.*')
        self.assertTrue(acl.canInvoke('client', 'bar'))
        acl.revokeInvoke('client')
        self.assertFalse(acl.canInvoke('client', 'bar'))

    def test_ACL_grant(self):
        acl = gear.ACL()
        acl.grantGrant('manager')
        self.assertTrue(acl.canGrant('manager'))
        acl.revokeGrant('manager')
        self.assertFalse(acl.canGrant('manager'))


def load_tests(loader, in_tests, pattern):
    return testscenarios.load_tests_apply_scenarios(loader, in_tests, pattern)
