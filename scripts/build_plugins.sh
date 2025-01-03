#!/bin/bash
#
# Builds the Obsidian plugins from their source code and moves the output to the plugins folder.
echo Building plugins

echo Current working directory
pwd

echo Updating submodules

git submodule update --init --recursive

excalidraw_folder_name="obsidian-excalidraw-plugin"
better_markdown_links_folder_name="better-markdown-links"
filename_heading_sync_folder_name="obsidian-filename-heading-sync"

for d in ./plugin-repositories/*/ ;
    do (
        cd $d

        echo Building plugin $d

        echo Current working directory
        pwd

        echo Installing dependencies

        npm i

        if [ $d == "./plugin-repositories/$excalidraw_folder_name/" ]; then
            echo Using build script build strategy
            npm run build
        elif [ $d == "./plugin-repositories/$better_markdown_links_folder_name/" ]; then
            echo Using Obsidian Dev Utils build strategy
            npx obsidian-dev-utils build
        elif [ $d == "./plugin-repositories/$filename_heading_sync_folder_name/" ]; then
            echo Using yarn build strategy
            npx yarn run build
        else
            echo Using normal build strategy
            node esbuild.config.mjs production
        fi

        echo Removing possible created lock files

        cd ../..

        echo Making sure directories exist

        echo Current working directory
        pwd

        p=${d//"./plugin-repositories/"/}

        echo Creating plugin directory
        echo $p

        mkdir -p ./plugins
        mkdir -p ./plugins/$p

        if [ $d == "./plugin-repositories/$excalidraw_folder_name/" ]; then
            echo Using dist folder movement strategy
            mv ${d}/dist/main.js ./plugins/${p}main.js
            mv ${d}/dist/manifest.json ./plugins/${p}manifest.json
            mv ${d}/dist/styles.css ./plugins/${p}styles.css
        elif [ $d == "./plugin-repositories/$better_markdown_links_folder_name/" ]; then
            echo Using dist/build folder movement strategy
            mv ${d}/dist/build/main.js ./plugins/${p}main.js
            mv ${d}/dist/build/manifest.json ./plugins/${p}manifest.json
        else
            echo Using standard movement strategy
            mv ${d}main.js ./plugins/${p}main.js
            cp ${d}manifest.json ./plugins/${p}manifest.json
            cp ${d}styles.css ./plugins/${p}styles.css
        fi
    );
done

echo Removing work folder

echo Current working directory
pwd

git submodule foreach git restore ./
