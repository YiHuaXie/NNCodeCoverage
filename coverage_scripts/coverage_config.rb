require 'xcodeproj'

def coverage_setup(recover)
  root_dir = Pod::Config.instance.installation_root
  destination_dir = "#{root_dir}/CodeCoverage"
  source_dir = File.dirname(__FILE__)

  `mkdir CodeCoverage` unless File.exist?(destination_dir)
  `cp -r #{source_dir}/coverage_env.sh #{destination_dir}`

  project_path = Dir.glob(File.join(root_dir, '*.xcodeproj')).first
  return unless project_path

  project = Xcodeproj::Project.open(project_path)
  main_target = project.targets.first

  unless main_target.shell_script_build_phases.map(&:display_name).include?('Code Coverage')
    phase = main_target.new_shell_script_build_phase('Code Coverage')
    phase.shell_script = '$SRCROOT/CodeCoverage/coverage_env.sh'
  end

  main_target.build_configurations.each do |config|
    build_settings = config.build_settings
    build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = '$(inherited) CODECOVERAGE=1'
    build_settings['OTHER_CFLAGS'] = recover ? '$(inherited)' : '$(inherited) -fprofile-instr-generate -fcoverage-mapping'
    build_settings['OTHER_SWIFT_FLAGS'] = recover ? '$(inherited)' : '$(inherited) -profile-generate -profile-coverage-mapping'
    build_settings['OTHER_LDFLAGS'] = recover ? '$(inherited)' : '$(inherited) -fprofile-instr-generate'
    build_settings['SWIFT_OPTIMIZATION_LEVEL'] = recover ? '' : '-Onone'
  end

  project.save
end

def coverage_pods_project_config(installer, recover)
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      build_settings = config.build_settings
      build_settings['OTHER_SWIFT_FLAGS'] = recover ? '$(inherited)' : '$(inherited) -profile-generate -profile-coverage-mapping'
      build_settings['OTHER_CFLAGS'] = recover ? '$(inherited)' : '$(inherited) -fprofile-instr-generate -fcoverage-mapping'
      build_settings['OTHER_LDFLAGS'] = recover ? '$(inherited)' : '$(inherited) -fprofile-instr-generate'
    end
  end
end

def coverage_static_frameworks_config(static_frameworks, installer)
  installer.pod_targets.each { |pod|
    if static_frameworks.include?(pod.name)
      def pod.build_type
        Pod::BuildType.static_framework
      end
    end
  }

  # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
  def installer.verify_no_static_framework_transitive_dependencies; end
end




