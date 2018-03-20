# GitLab

Various GitLab hooks. For more information please read a series of articles on Continuous Delivery of your InterSystems solution using GitLab:

- [Part I: Git](https://community.intersystems.com/post/continuous-delivery-your-intersystems-solution-using-gitlab-part-i-git)
- [Part II: GitLab workflow](https://community.intersystems.com/post/continuous-delivery-your-intersystems-solution-using-gitlab-part-ii-gitlab-workflow)
- [Part III: GitLab installation and configuration](https://community.intersystems.com/post/continuous-delivery-your-intersystems-solution-using-gitlab-part-iii-gitlab-installation-and) 
- [Part IV: CD configuration](https://community.intersystems.com/post/continuous-delivery-your-intersystems-solution-using-gitlab-part-iv-cd-configuration)

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
| tests   | MyApp/Tests             | Path relative from the repo root to the test suite.                                                 |
| commit  |                        | Do not set. Current commit hash.                                                                |
| init    | Package.Class:Method   | Code called before loading files.                                                               |
| delete  | Package.Class:Method   | Code called to delete files from project. Should accept one argument - list of files to delete. |
| url     | http://127.0.0.1:57772 | Server root.                                                                                    |
