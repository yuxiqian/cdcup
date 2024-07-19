#!/usr/bin/env ruby
# frozen_string_literal: true

require 'tty-prompt'
require 'yaml'

require_relative 'source/my_sql'
require_relative 'source/values_source'

require_relative 'sink/doris'
require_relative 'sink/star_rocks'
require_relative 'sink/values_sink'

@prompt = TTY::Prompt.new

@docker_compose_file_content = {
  'services' => {}
}

@pipeline_yaml_file_content = {
  'pipeline' => {
    'parallelism' => 1
  }
}

SOURCES = {
  mysql: MySQL,
  values: ValuesSource
}.freeze

SINKS = {
  doris: Doris,
  starrocks: StarRocks,
  values: ValuesSink
}.freeze

FLINK_VERSIONS = %w[
  1.17.2
  1.18.1
  1.19.1
].freeze

@prompt.say 'Welcome to cdc-up quickstart wizard!'
@prompt.say 'Answer few questions before we can start:'

flink_version = @prompt.select('Which Flink version would you like to use?', FLINK_VERSIONS, default: FLINK_VERSIONS.last)

@docker_compose_file_content['services']['jobmanager'] = {
  'image' => "flink:#{flink_version}-scala_2.12",
  'hostname' => 'jobmanager',
  'ports' => ['8081'],
  'command' => 'jobmanager',
  'environment' => {
    'FLINK_PROPERTIES' => 'jobmanager.rpc.address: jobmanager'
  }
}

@docker_compose_file_content['services']['taskmanager'] = {
  'image' => "flink:#{flink_version}-scala_2.12",
  'hostname' => 'taskmanager',
  'command' => 'taskmanager',
  'environment' => {
    'FLINK_PROPERTIES' => "jobmanager.rpc.address: jobmanager\ntaskmanager.numberOfTaskSlots: 4"
  }
}

source = @prompt.select('Which data source to use?', SOURCES.keys)
sink = @prompt.select('Which data sink to use?', SINKS.keys)

SOURCES[source].prepend_to_docker_compose_yaml(@docker_compose_file_content)
SOURCES[source].prepend_to_pipeline_yaml(@pipeline_yaml_file_content)
SINKS[sink].prepend_to_docker_compose_yaml(@docker_compose_file_content)
SINKS[sink].prepend_to_pipeline_yaml(@pipeline_yaml_file_content)

File.write('/conf/docker-compose.yaml', YAML.dump(@docker_compose_file_content))
File.write('/conf/pipeline-definition.yaml', YAML.dump(@pipeline_yaml_file_content))
