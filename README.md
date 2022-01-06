# CodePush Backwards Compatibility Check Action

Actions responsible to validate if the backwards compatibility (based on the git SHA differentiation).

## :rocket: Usage

An example workflow to use it:

```yaml
name: Mobile Continuous Delivery

on: 
  pull_request:
    branches:
      - main
      - develop
      - rc-*
      - hotfix-*

jobs:
  build: 
    runs-on: ubuntu-latest
    outputs:
      is_backwards_compatible: ${{ steps.backwards_compatible.outputs.is_backwards_compatible }}
    steps:
      - uses: actions/checkout@v2

      - run: yarn install

      - working_directory: ./android
        run: bundle exec fastlane build_release_bundle

      - name: Release Compatibility Check
        id: backwards_compatible
        uses: ./.github/github-actions/codepush-backwards-compatibility-check
        with: 
          before_commit_sha: ${{ github.event_name == 'pull_request' && github.event.pull_request.base.sha || github.event_name == 'push' && github.event.before }}
          after_commit_sha: ${{ github.sha }}
          package_json_path: package.json
          android_path: android/
          ios_path: ios/
          yarn_lock_path: yarn.lock

  deploy_app_center: 
    runs-on: ubuntu-latest
    needs: build
    if: needs.build.outputs.is_backwards_compatible == 'true'
    steps:
      - uses: actions/checkout@v2

      - run: yarn install

      - env:
          APP_CENTER_TOKEN: ${{ secrets.APP_CENTER_TOKEN }}
          APP_VERSION: ${{ secrets.APP_VERSION }}
        run: appcenter codepush release -a mobile-project/android -d staging -c ./codepush --token ${{ env.APP_CENTER_TOKEN }} --disable-duplicate-release-error --t ${{ env.APP_VERSION }}
```

## :gear: Inputs

| Name              | Description                            |   Default    | Required |
| ----------------- | -------------------------------------- | :----------: | :------: |
| before_commit_sha | The SHA of the commit before the merge |              |   True   |
| after_commit_sha  | The SHA of the commit after the merge  |              |   True   |
| package_json_path | The path to the package.json file      | package.json |  False   |
| android_path      | The path to the Android project        |   android/   |  False   |
| ios_path          | The path to the iOS project            |     ios/     |  False   |
| yarn_lock_path    | The path to the yarn.lock file         |  yarn.lock   |  False   |

## :gear: Outputs

| Name                    | Description                              | Default |
| ----------------------- | ---------------------------------------- | :-----: |
| is_backwards_compatible | The codepush deployment condition result |         |

## :thought_balloon: Support

If you find our work useful, but for some reason there is something missing, please raise a pull request to us review it!