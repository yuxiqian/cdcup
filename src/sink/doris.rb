# frozen_string_literal: true


# Doris sink definition generator class.
class Doris
  def self.prepend_to_docker_compose_yaml(docker_compose_yaml)
    docker_compose_yaml['services']['doris'] = {
      'image' => 'apache/doris:doris-all-in-one-2.1.0',
      'hostname' => 'doris',
      'ports' => %w[8030 8040 9030]
    }
  end

  def self.prepend_to_pipeline_yaml(pipeline_yaml)
    pipeline_yaml['sink'] = {
      'type' => 'doris',
      'fenodes' => 'doris:8030',
      'username' => 'root',
      'password' => '',
      'table.create.properties.light_schema_change' => true,
      'table.create.properties.replication_num' => 1
    }
  end
end