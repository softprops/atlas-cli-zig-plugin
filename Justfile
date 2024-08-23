local_plugin_path := config_directory() / "/atlascli/plugins/atlas-cli-zig-plugin/"

test:
    @echo {{ local_plugin_path }}

install: package
    @mkdir -p "{{local_plugin_path}}"
    @cp zig-out/bin/atlas-cli-zig-plugin "{{local_plugin_path}}"
    @cp manifest.yml "{{local_plugin_path}}"
    @echo installed at "{{local_plugin_path}}"

package:
    @zig build
    @VERSION=0.1.0 \
    GITHUB_REPOSITORY_OWNER=repo-owner \
    GITHUB_REPOSITORY_NAME=repo-name \
    BINARY=atlas-cli-zig-plugin \
    envsubst < manifest.template.yml > manifest_temp.yml && mv manifest_temp.yml manifest.yml

atlas-install:
    @atlas plugin install softprops/atlas-cli-zig-plugin
