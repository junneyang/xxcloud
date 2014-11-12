/*  vim:expandtab:shiftwidth=2:tabstop=2:smarttab:
 * 
 *  Gearmand client and server library.
 *
 *  Copyright (C) 2011 Data Differential, http://datadifferential.com/
 *  Copyright (C) 2008 Brian Aker, Eric Day
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

#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <string>

#include <libgearman/gearman.h>
#include <boost/program_options.hpp>

#include "util/string.hpp"
#include "gearmand/error.hpp"

#ifndef __INTEL_COMPILER
#pragma GCC diagnostic ignored "-Wold-style-cast"
#endif

#define REVERSE_TASKS 10

static gearman_return_t created(gearman_task_st *task);
static gearman_return_t data(gearman_task_st *task);
static gearman_return_t status(gearman_task_st *task);
static gearman_return_t complete(gearman_task_st *task);
static gearman_return_t fail(gearman_task_st *task);

int main(int args, char *argv[])
{
  gearmand::error::init(argv[0]);

  in_port_t port;
  int timeout;
  std::string host;
  std::string text_to_echo;

  boost::program_options::options_description desc("Options");
  desc.add_options()
    ("help", "Options related to the program.")
    ("verbose", "Send status to stdout")
    ("host,h", boost::program_options::value<std::string>(&host)->default_value("localhost"),"Connect to the host")
    ("port,p", boost::program_options::value<in_port_t>(&port)->default_value(GEARMAN_DEFAULT_TCP_PORT), "Port number use for connection")
    ("timeout,u", boost::program_options::value<int>(&timeout)->default_value(-1), "Timeout in milliseconds")
    ("text", boost::program_options::value<std::string>(&text_to_echo), "Text used for echo")
            ;

  boost::program_options::positional_options_description text_options;
  text_options.add("text", -1);

  boost::program_options::variables_map vm;
  try
  {
    boost::program_options::store(boost::program_options::command_line_parser(args, argv).
                                  options(desc).positional(text_options).run(), vm);
    boost::program_options::notify(vm);
  }
  catch(std::exception &e)
  { 
    std::cout << e.what() << std::endl;
    return EXIT_FAILURE;
  }

  if (vm.count("help"))
  {
    std::cout << desc << std::endl;
    return EXIT_SUCCESS;
  }

  if (vm.count("verbose") == 0)
  {
    close(STDOUT_FILENO);
  }

  gearman_client_st client;
  if (gearman_client_create(&client) == NULL)
  {
    gearmand::error::message("Memory allocation failure on client creation");
    return EXIT_FAILURE;
  }

  gearman_return_t ret;
  ret= gearman_client_add_server(&client, host.c_str(), port);
  if (ret != GEARMAN_SUCCESS)
  {
    gearmand::error::message(gearman_client_error(&client));
    gearman_client_free(&client);
    return EXIT_FAILURE;
  }

  gearman_task_st task[REVERSE_TASKS];
  for (uint32_t x= 0; x < REVERSE_TASKS; x++)
  {
    if (gearman_client_add_task(&client, &(task[x]), NULL, "reverse", NULL,
                                text_to_echo.c_str(), text_to_echo.size(),
                                &ret) == NULL ||
        ret != GEARMAN_SUCCESS)
    {
      gearmand::error::message(gearman_client_error(&client));
      gearman_client_free(&client);
      return EXIT_FAILURE;
    }
  }

  gearman_client_set_created_fn(&client, created);
  gearman_client_set_data_fn(&client, data);
  gearman_client_set_status_fn(&client, status);
  gearman_client_set_complete_fn(&client, complete);
  gearman_client_set_fail_fn(&client, fail);

  ret= gearman_client_run_tasks(&client);
  if (ret != GEARMAN_SUCCESS)
  {
    gearmand::error::message(gearman_client_error(&client));
    gearman_client_free(&client);
    return EXIT_FAILURE;
  }

  gearman_client_free(&client);

  return EXIT_SUCCESS;
}

static gearman_return_t created(gearman_task_st *task)
{
  std::cout << "Created: " << gearman_task_job_handle(task) << std::endl;

  return GEARMAN_SUCCESS;
}

static gearman_return_t data(gearman_task_st *task)
{
  std::cout << "Data: " << gearman_task_job_handle(task) << " ";
  std::cout.write((char *)gearman_task_data(task), gearman_task_data_size(task));
  std::cout << std::endl;

  return GEARMAN_SUCCESS;
}

static gearman_return_t status(gearman_task_st *task)
{
  std::clog << "Status: " 
    << gearman_task_job_handle(task) 
    << " (" << gearman_task_numerator(task) << "/" << gearman_task_denominator(task) << ")" 
    << std::endl;

  return GEARMAN_SUCCESS;
}

static gearman_return_t complete(gearman_task_st *task)
{
  std::cout << "Completed: " << gearman_task_job_handle(task) << " ";
  std::cout.write((char *)gearman_task_data(task), gearman_task_data_size(task));
  std::cout << std::endl;

  return GEARMAN_SUCCESS;
}

static gearman_return_t fail(gearman_task_st *task)
{
  std::cerr << "Failed: " << gearman_task_job_handle(task) << std::endl;
  return GEARMAN_SUCCESS;
}
