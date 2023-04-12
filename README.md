# Field-Permission-Viewer

It is easy to see the set of field permissions for a given user on a given object.

## Installing the app using a Scratch Org

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:

    - Enable Dev Hub in your Trailhead Playground
    - Install Salesforce CLI
    - Install Visual Studio Code
    - Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension

1. If you haven't already done so, authorize your hub org and provide it with an alias (**mydevhuborg** in the command below):

    ```
    sfdx auth:web:login -d -a mydevhuborg
    ```

1. Clone the Field-Permission-Viewer repository:

    ```
    git clone https://github.com/dyncan/Field-Permission-Viewer.git
    cd Field-Permission-Viewer
    ```

1. Create a scratch org and provide it with an alias (**lwc-field-viewer** in the command below):

    ```
    sfdx force:org:create -s -f config/project-scratch-def.json -a lwc-field-viewer
    ```

1. Push the app to your scratch org:

    ```
    sfdx force:source:push
    ```
2. Open the scratch org:

    ```
    sfdx force:org:open
    ```
