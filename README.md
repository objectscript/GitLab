# GitLab

Various GitLab hooks. For more information please read a series of articles on Continuous Delivery of your InterSystems solution using GitLab:

- [Part I: Git](https://community.intersystems.com/post/continuous-delivery-your-intersystems-solution-using-gitlab-part-i-git)
- [Part II: GitLab workflow](https://community.intersystems.com/post/continuous-delivery-your-intersystems-solution-using-gitlab-part-ii-gitlab-workflow)
- [Part III: GitLab installation and configuration](https://community.intersystems.com/post/continuous-delivery-your-intersystems-solution-using-gitlab-part-iii-gitlab-installation-and) 
- [Part IV: CD configuration](https://community.intersystems.com/post/continuous-delivery-your-intersystems-solution-using-gitlab-part-iv-cd-configuration)
- [Part V: Why containers?](https://community.intersystems.com/post/continuous-delivery-your-intersystems-solution-using-gitlab-part-v-why-containers)

# Installation

Load and compile classes. 

## Development

Development is done on [Cache-Tort-Git UDL fork](https://github.com/MakarovS96/cache-tort-git).

## Use

Set settings via:  `write ##class(isc.git.Settings).setSetting("setting", "value")`

Available settings:

| Setting | Sample Value           | Description                                                                                     |
|---------|------------------------|-------------------------------------------------------------------------------------------------|
| ext     | $lb("xml")             | List of files extensions to load and compile.                                                   |
| tests   | MyApp/Tests            | Path relative from the repo root to the test suite.                                             |
| commit  |                        | Do not set. Current commit hash.                                                                |
| hooks   | MyApp/Hooks/           | Path relative from the repo root to the hooks.                                                  |
| delete  | Package.Class:Method   | Code called to delete files from project. Should accept one argument - list of files to delete. |
| url     | http://127.0.0.1:57772 | Server root.                                                                                    |


## Hooks

There are two types of hooks available:

- **Global** - executed each time the CI is run. Extend `isc.git.hook.Global`. 
- **Local** - executed once. Extend `isc.git.hook.Local`.

Hooks of the same type are executed in collation order. To create a hook extend either or `isc.git.hook.Global` or `isc.git.hook.Local` and implement `onBefore` and/or `onAfter` methods.

## Tips & Tricks

Various tricks for GitLab CI.

### Namespaces

Use `CI_COMMIT_REF_NAME` (resolves to branch) environment variable to use several namespaces on one server. 

I.e. `csession ensemble -U ${CI_COMMIT_REF_NAME} "##class(isc.git.GitLab).loadDiff()"`
