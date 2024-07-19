# frozen_string_literal: true

# MySQL source definition generator class.
class MySQL
  class << self
    def prepend_to_docker_compose_yaml(docker_compose_yaml)
      docker_compose_yaml['services']['mysql'] = {
        'image' => 'mysql:8.0',
        'hostname' => 'mysql',
        'environment' => {
          'MYSQL_ALLOW_EMPTY_PASSWORD' => true,
          'MYSQL_DATABASE' => 'cdcup'
        },
        'ports' => ['3306']
      }
    end

    def prepend_to_pipeline_yaml(pipeline_yaml)
      pipeline_yaml['source'] = {
        'type' => 'mysql',
        'hostname' => 'mysql',
        'port' => 3306,
        'username' => 'root',
        'password' => '',
        'tables' => 'cdcup.\.*',
        'server-id' => '5400-6400',
        'server-time-zone' => 'UTC'
      }
    end
  end
end
