#
# Cookbook Name:: rabbitmq-in-depth
# Recipe:: default
#
# Copyright 2013 Manning Publications
#

# Ensure the libraries used in the Python examples are always up to date
%w[pika pamqp rabbitpy].each do |pkg|
  python_pip pkg do
    action [:install, :upgrade]
  end
end

# Reset the permissions on the git clone
directory '/opt/rabbitmq-in-depth' do
  action    :nothing
  owner     'vagrant'
  group     'vagrant'
  mode      0644
  recursive true
end

# Clone the git resources for the book
git '/opt/rabbitmq-in-depth' do
  repository 'https://github.com/gmr/RabbitMQ-in-Depth.git'
  revision  'HEAD'
  action    :sync
  notifies :create, 'directory[/opt/rabbitmq-in-depth]'
end

# Remove any extraneous packages
execute 'package-cleanup' do
  command 'apt-get -y autoremove'
end
