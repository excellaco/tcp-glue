# Glue

This is where you run and manage the services that make up the app. 

You can:

* **Clone all repositories** (in the .repos file). If new ones are added it can be run again: `./git-clone-all`. Get onboarding developers running fast.
* **Start up multiple services**: including core services at once, and specified individual services, all on the same network so they can talk. Service names are listed in .repos and in the ./run file:
    ```
    ./run core    # Starts main app services

    ./run <SERVICE NAME or ALIAS>

    ./run db      # Start just a database
    ```
* **Update/pull all repos**: `./git-pull-all`
    
## Setup

1. Add more available memory for Docker to handle many services running locally: `Under Docker > Preferences > Advanced` and set the following: 
Memory: 4 Gb

1. Clone this repo and cd into it

1. Go into the directory of the clone, and clone all the target repos by running `./git-clone-all`

    All of the repos you want to work with will be subdirectories and managed by glue like this:

    ```
    glue
    └── repo 1
    └── repo 2
    ...
    └── repo x
    ```

1. You can run `./git-pull-all` to update all of the managed repos.

## Contributing

There are a few rules to follow when making changes to the repo:

Try not to make Dockerfile changes unless you need to. This causes folks to need to rebuild their images when pulling down the latest changes, which takes a while.

We use the Major.Minor.Patch version strategy, enforced by git hooks:  
Major: indicates a breaking change that must require a rebuild immediately (use major++ in your commit message to bump the major version)  
Minor: a significant change that may suggests a rebuild (use minor++ in your commit message to bump the major version)  
Patch: a non-Dockerfile change that will not break anything (patch versions are automatically bumped on each commit)
