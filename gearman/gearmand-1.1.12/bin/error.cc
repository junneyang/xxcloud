/*  vim:expandtab:shiftwidth=2:tabstop=2:smarttab:
 * 
 *  DataDifferential Utility Library
 *
 *  Copyright (C) 2011 Data Differential, http://datadifferential.com/
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *      * Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *
 *      * Redistributions in binary form must reproduce the above
 *  copyright notice, this list of conditions and the following disclaimer
 *  in the documentation and/or other materials provided with the
 *  distribution.
 *
 *      * The names of its contributors may not be used to endorse or
 *  promote products derived from this software without specific prior
 *  written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include "gear_config.h"

#include <cerrno>
#include <cstdio>
#include <cstring>
#include <iostream>

#include <libgearman/gearman.h>
#include <bin/error.h>

namespace gearman_client {

namespace error {

void perror(const char *message)
{
  char *errmsg_ptr;
  char errmsg[BUFSIZ];
  errmsg[0]= 0;
  errmsg_ptr= errmsg;

#ifdef STRERROR_R_CHAR_P
  errmsg_ptr= strerror_r(errno, errmsg, sizeof(errmsg));
#else
  if (strerror_r(errno, errmsg, sizeof(errmsg)) == 0)
  {
    errmsg_ptr= errmsg;
  }
#endif
  if (errmsg_ptr and errmsg[0] != 0)
  std::cerr << "gearman: " << message << " (" << errmsg_ptr << ")" << std::endl;
}

void message(const char *arg)
{
  std::cerr << "gearman: " << arg << std::endl;
}

void message(const char *arg, const char *arg2)
{
  std::cerr << "gearman: " << arg << " : " << arg2 << std::endl;
}

void message(const std::string &arg, gearman_return_t rc)
{
  std::cerr << "gearman: " << arg << " : " << gearman_strerror(rc) << std::endl;
}

void message(const char *arg, const gearman_client_st* client)
{
  std::cerr << "gearman: " << arg << " : " << gearman_client_error(client) << std::endl;
}

void message(const char *arg, const gearman_worker_st* worker)
{
  std::cerr << "gearman: " << arg << " : " << gearman_worker_error(worker) << std::endl;
}

} // namespace error

} /* namespace gearman_client */
