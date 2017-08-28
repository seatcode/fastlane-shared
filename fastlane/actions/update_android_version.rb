module Fastlane
  module Actions
    module SharedValues
      ANDROID_VERSION_NAME = :ANDROID_VERSION_NAME
      ANDROID_VERSION_CODE = :ANDROID_VERSION_CODE
    end

    class UpdateAndroidVersionAction < Action

      def self.run(params)
        version_name = params[:version_name]
        version_code = params[:version_code]
        autoincrement = params[:autoincrement] #will only work if version_code is not passed
        project_root = params[:gradle_root]
        version_name_key = params[:version_name_key]
        version_code_key = params[:version_code_key]

        if version_code.nil? && autoincrement
          currentVersionCode = getBuildValue(project_root, version_code_key).to_i
          setBuildValue(project_root, version_code_key, currentVersionCode + 1)
          version_code = getBuildValue(project_root, version_code_key)
        elsif version_code != nil
          setBuildValue(project_root, version_code_key, version_code)
        else
          version_code = getBuildValue(project_root, version_code_key)
        end

        if version_name != nil
          setBuildValue(project_root, version_name_key, version_name)
        else
          version_name = getBuildValue(project_root, version_name_key)
        end

        UI.message "Name: #{version_name} Code: #{version_code}".blue

        Actions.lane_context[SharedValues::ANDROID_VERSION_NAME] = version_name
        Actions.lane_context[SharedValues::ANDROID_VERSION_CODE] = version_code
      end

      def self.getBuildValue(fileFolder, key)
        value = ""
        found = false
        Dir.glob("#{fileFolder}/build.gradle") do |path|
          begin
            File.open(path, 'r') do |file|
              file.each_line do |line|
                unless line.include? "#{key}" and !found
                  next
                end
                components = line.strip.split(' ')
                value = components.last.tr("\"", "").tr("\'", "")
                break
              end
              file.close
            end
          end
        end
        return value
      end

      def self.setBuildValue(fileFolder, key, newValue)
        found = false
        Dir.glob("#{fileFolder}/build.gradle") do |path|
          begin
            temp_file = Tempfile.new('versioning')
            File.open(path, 'r') do |file|
              file.each_line do |line|
                unless line.include? "#{key} " and !found
                  temp_file.puts line
                  next
                end
                components = line.strip.split(' ')
                value = components.last.tr("\"", "").tr("\'", "")
                line.replace line.sub(value, newValue.to_s)
                found = true
                temp_file.puts line
              end
              file.close
            end
            temp_file.rewind
            temp_file.close
            FileUtils.mv(temp_file.path, path)
            temp_file.unlink
          end
        end
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Changes app build number and pushes the change to a specific branch"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version_name,
                                       env_name: "UPDATE_ANDROID_VERSION_NAME",
                                       description: "Version name (ak 1.0.2",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :version_code,
                                       env_name: "UPDATE_ANDROID_VERSION_CODE",
                                       description: "Version code (ak build number)",
                                       optional: true),  
          FastlaneCore::ConfigItem.new(key: :autoincrement,
                                       env_name: "UPDATE_ANDROID_VERSION_AUTOINCREMENT",
                                       description: "TRUE if you want to autoincrement the Version code",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :gradle_root,
                                       env_name: "UPDATE_ANDROID_VERSION_GRADLE_ROOT",
                                       description: "[Optional] Path to the build.gradle root. If not provided will use current directory",
                                       default_value: ".",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :version_name_key,
                                       env_name: "UPDATE_ANDROID_VERSION_NAME_KEY",
                                       description: "[Optional] Key for the version name value on the gradle file",
                                       default_value: "versionName",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :version_code_key,
                                       env_name: "UPDATE_ANDROID_VERSION_CODE_KEY",
                                       description: "[Optional] Key for the version code value on the gradle file",
                                       default_value: "versionCode",
                                       optional: true),
        ]
      end

      def self.output
        [
          ['ANDROID_VERSION_NAME', 'The new version name'],
          ['ANDROID_VERSION_CODE', 'The new version code']
        ]
      end

      def self.author
        'Eli Kohen'
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
