# Copyright 2013 OpenStack Foundation
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

"""
Protocol Constants
==================

These are not necessary for normal API usage.  See the `Gearman
protocol reference <http://gearman.org/protocol>`_ for an explanation
of each of these.

Magic Codes
-----------

.. py:data:: REQ

   The Gearman magic code for a request.

.. py:data:: RES

   The Gearman magic code for a response.

Packet Types
------------

"""

types = {
    1: 'CAN_DO',
    2: 'CANT_DO',
    3: 'RESET_ABILITIES',
    4: 'PRE_SLEEP',
    #unused
    6: 'NOOP',
    7: 'SUBMIT_JOB',
    8: 'JOB_CREATED',
    9: 'GRAB_JOB',
    10: 'NO_JOB',
    11: 'JOB_ASSIGN',
    12: 'WORK_STATUS',
    13: 'WORK_COMPLETE',
    14: 'WORK_FAIL',
    15: 'GET_STATUS',
    16: 'ECHO_REQ',
    17: 'ECHO_RES',
    18: 'SUBMIT_JOB_BG',
    19: 'ERROR',
    20: 'STATUS_RES',
    21: 'SUBMIT_JOB_HIGH',
    22: 'SET_CLIENT_ID',
    23: 'CAN_DO_TIMEOUT',
    24: 'ALL_YOURS',
    25: 'WORK_EXCEPTION',
    26: 'OPTION_REQ',
    27: 'OPTION_RES',
    28: 'WORK_DATA',
    29: 'WORK_WARNING',
    30: 'GRAB_JOB_UNIQ',
    31: 'JOB_ASSIGN_UNIQ',
    32: 'SUBMIT_JOB_HIGH_BG',
    33: 'SUBMIT_JOB_LOW',
    34: 'SUBMIT_JOB_LOW_BG',
    35: 'SUBMIT_JOB_SCHED',
    36: 'SUBMIT_JOB_EPOCH',
}

for i, name in types.items():
    globals()[name] = i
    __doc__ += '\n.. py:data:: %s\n' % name

REQ = b'\x00REQ'
RES = b'\x00RES'
