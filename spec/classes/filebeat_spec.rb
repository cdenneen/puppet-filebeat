require 'spec_helper'

describe 'filebeat', type: :class do
  let :facts do
    {
      kernel: 'Linux',
      osfamily: 'Debian',
      lsbdistid: 'Ubuntu',
      lsbdistrelease: '16.04',
      rubyversion: '1.9.3',
      puppetversion: Puppet.version
    }
  end

  context 'defaults' do
    it { is_expected.to contain_package('filebeat') }
    it { is_expected.to contain_anchor('filebeat::begin') }
    it { is_expected.to contain_anchor('filebeat::end') }
    it { is_expected.to contain_class('filebeat::install') }
    it { is_expected.to contain_class('filebeat::config') }
    it { is_expected.to contain_anchor('filebeat::install::begin') }
    it { is_expected.to contain_anchor('filebeat::install::end') }
    it { is_expected.to contain_class('filebeat::install::linux') }
    it { is_expected.to contain_class('filebeat::repo') }
    it { is_expected.to contain_class('filebeat::service') }
    it { should_not contain_class('filebeat::install::windows') }
    it do
      is_expected.to contain_file('filebeat.yml').with(
        path: '/etc/filebeat/filebeat.yml',
        mode: '0644'
      )
    end
    it do
      is_expected.to contain_file('filebeat-config-dir').with(
        ensure: 'directory',
        path: '/etc/filebeat/conf.d',
        mode: '0755',
        recurse: true
      )
    end
    it do
      is_expected.to contain_service('filebeat').with(
        enable: true,
        ensure: 'running',
        provider: nil
      )
    end
    it do
      is_expected.to contain_apt__source('beats').with(
        location: 'http://packages.elastic.co/beats/apt',
        key: {
          'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
          'source' => 'http://packages.elastic.co/GPG-KEY-elasticsearch'
        }
      )
    end
  end

  describe 'on a RHEL system' do
    let :facts do
      {
        kernel: 'Linux',
        osfamily: 'RedHat',
        rubyversion: '1.8.7',
        puppetversion: Puppet.version
      }
    end

    it do
      is_expected.to contain_yumrepo('beats').with(
        baseurl: 'https://packages.elastic.co/beats/yum/el/$basearch',
        gpgkey: 'http://packages.elastic.co/GPG-KEY-elasticsearch'
      )
    end

    it do
      is_expected.to contain_service('filebeat').with(
        enable: true,
        ensure: 'running',
        provider: 'redhat'
      )
    end
  end

  describe 'on a Windows system' do
    let :facts do
      {
        kernel: 'Windows',
        rubyversion: '1.9.3',
        puppetversion: Puppet.version
      }
    end

    it { is_expected.to contain_class('filebeat::install::windows') }
    it { should_not contain_class('filebeat::install::linux') }
    it { is_expected.to contain_file('filebeat.yml').with_path('C:/Program Files/Filebeat/filebeat.yml') }
    it do
      is_expected.to contain_file('filebeat-config-dir').with(
        ensure: 'directory',
        path: 'C:/Program Files/Filebeat/conf.d',
        recurse: true
      )
    end
    it do
      is_expected.to contain_service('filebeat').with(
        enable: true,
        ensure: 'running',
        provider: nil
      )
    end
  end

  describe 'on a Solaris system' do
    let :facts do
      {
        osfamily: 'Solaris'
      }
    end
    context 'it should fail as unsupported' do
      it { expect { should raise_error(Puppet::Error) } }
    end
  end
end
