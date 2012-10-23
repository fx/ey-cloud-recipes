#
# Cookbook Name:: nodejs
# Recipe:: default
#
# Build and install node.js
#
# From https://gist.github.com/970051

if ['app','app_master','solo'].include?(node[:instance_role])
  version_tag     = "v0.9.2"
  source_base_dir = "/data/nodejs"
  source_dir      = "#{source_base_dir}/#{version_tag}"
  install_dir     = "/usr/bin"

  ey_cloud_report "node.js" do
    message "Setting up node.js"
  end

  ey_cloud_report "nodejs" do
    message "configuring nodejs #{version_tag}"
  end

  directory "#{source_base_dir}" do
    owner 'root'
    group 'root'
    mode 0755
    recursive true
  end
  
  # download nodejs source and checkout specific version
  execute "fetch nodejs from GitHub" do
    command "git clone https://github.com/joyent/node.git #{source_dir} && cd #{source_dir} && git checkout #{version_tag}"
    not_if { FileTest.exists?(source_dir) }
  end

  # See: https://github.com/joyent/node/issues/4186
  execute "prepare nodejs" do
    command "perl -pi -e \"s/'-Wno-old-style-declaration',//\" #{source_dir}/deps/openssl/openssl.gyp"
  end

  execute "configure nodejs" do
    command "cd #{source_dir} && ./configure"
    not_if { FileTest.exists?("#{source_dir}/node") }
  end

  execute "build nodejs" do
    command "cd #{source_dir} && make"
    not_if { FileTest.exists?("#{source_dir}/node") }
  end

  execute "symlink nodejs" do
    command "ln -sf #{source_dir}/node #{install_dir}/node"
  end

  execute "symlink npm" do
    command "ln -sf #{source_dir}/deps/npm/bin/npm-cli.js #{install_dir}/npm"
  end
end