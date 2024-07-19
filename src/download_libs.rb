# frozen_string_literal: true

CDC_VERSIONS = {
  '3.0.0': {
    tar: 'https://github.com/ververica/flink-cdc-connectors/releases/download/release-3.0.0/flink-cdc-3.0.0-bin.tar.gz',
    connectors: %w[
      https://repo1.maven.org/maven2/com/ververica/flink-cdc-pipeline-connector-doris/3.0.0/flink-cdc-pipeline-connector-doris-3.0.0.jar
      https://repo1.maven.org/maven2/com/ververica/flink-cdc-pipeline-connector-mysql/3.0.0/flink-cdc-pipeline-connector-mysql-3.0.0.jar
      https://repo1.maven.org/maven2/com/ververica/flink-cdc-pipeline-connector-starrocks/3.0.0/flink-cdc-pipeline-connector-starrocks-3.0.0.jar
      https://repo1.maven.org/maven2/com/ververica/flink-cdc-pipeline-connector-values/3.0.0/flink-cdc-pipeline-connector-values-3.0.0.jar
    ]
  },
  '3.0.1': {
    tar: 'https://github.com/ververica/flink-cdc-connectors/releases/download/release-3.0.1/flink-cdc-3.0.1-bin.tar.gz',
    connectors: %w[
      https://repo1.maven.org/maven2/com/ververica/flink-cdc-pipeline-connector-doris/3.0.1/flink-cdc-pipeline-connector-doris-3.0.1.jar
      https://repo1.maven.org/maven2/com/ververica/flink-cdc-pipeline-connector-mysql/3.0.1/flink-cdc-pipeline-connector-mysql-3.0.1.jar
      https://repo1.maven.org/maven2/com/ververica/flink-cdc-pipeline-connector-starrocks/3.0.1/flink-cdc-pipeline-connector-starrocks-3.0.1.jar
      https://repo1.maven.org/maven2/com/ververica/flink-cdc-pipeline-connector-values/3.0.1/flink-cdc-pipeline-connector-values-3.0.1.jar
    ]
  },
  '3.1.0': {
    tar: 'https://dlcdn.apache.org/flink/flink-cdc-3.1.0/flink-cdc-3.1.0-bin.tar.gz',
    connectors: %w[
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-mysql/3.1.0/flink-cdc-pipeline-connector-mysql-3.1.0.jar
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-doris/3.1.0/flink-cdc-pipeline-connector-doris-3.1.0.jar
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-starrocks/3.1.0/flink-cdc-pipeline-connector-starrocks-3.1.0.jar
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-kafka/3.1.0/flink-cdc-pipeline-connector-kafka-3.1.0.jar
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-paimon/3.1.0/flink-cdc-pipeline-connector-paimon-3.1.0.jar
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-values/3.1.0/flink-cdc-pipeline-connector-values-3.1.0.jar
    ]
  },
  '3.1.1': {
    tar: 'https://dlcdn.apache.org/flink/flink-cdc-3.1.1/flink-cdc-3.1.1-bin.tar.gz',
    connectors: %w[
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-mysql/3.1.1/flink-cdc-pipeline-connector-mysql-3.1.1.jar
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-doris/3.1.1/flink-cdc-pipeline-connector-doris-3.1.1.jar
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-starrocks/3.1.1/flink-cdc-pipeline-connector-starrocks-3.1.1.jar
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-kafka/3.1.1/flink-cdc-pipeline-connector-kafka-3.1.1.jar
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-paimon/3.1.1/flink-cdc-pipeline-connector-paimon-3.1.1.jar
      https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-values/3.1.1/flink-cdc-pipeline-connector-values-3.1.1.jar
    ]
  }
}.freeze

def download_cdc_bin(version, dest_path)
  cdc_version = CDC_VERSIONS[version]
  puts "\tDownloading #{File.basename(cdc_version[:tar])}..."
  `wget -q -O /tmp/cdc-bin.tar.gz #{cdc_version[:tar]}`
  `tar --strip-components=1 -xzvf /tmp/cdc-bin.tar.gz -C #{dest_path}`
end

def download_connectors(version, dest_path, connectors)
  CDC_VERSIONS[version][:connectors].each do |link|
    jar_name = File.basename(link)
    if connectors.any? { |c| jar_name.include? c }
      puts "\tDownloading #{jar_name}..."
      `wget -q -O /#{dest_path}/lib/#{jar_name}.jar #{link}`
    end
  end
end

def download_mysql_driver(dest_path)
  `wget -q https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.27/mysql-connector-java-8.0.27.jar \
  -O #{dest_path}/lib/mysql-connector-java.jar`
end

def download_cdc(version, dest_path, connectors = [])
  download_cdc_bin(version.to_sym, dest_path)
  download_connectors(version.to_sym, dest_path, connectors)
  download_mysql_driver(dest_path)
end