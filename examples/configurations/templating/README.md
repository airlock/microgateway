# Description
This folder contains example manifest files to be used with kustomize for the templating use-case. With this use-case one defines a base template (analogous to the `templates` folder) that contains the base configuration,
which can be reused by a varity of application deployments. To override configuration elements of the template, apply a kustomization manifest file on top of the template (See [kustomize](https://kustomize.io/) for more information).
The folder `templates` contains the template manifest files that are referenced in the `kustomization.yaml` file which applies various patches to the resources. Instead of a folder it is possible to reference a git repository which contains the templates. To use a remote target change the `resources` in the kustomization file as follows:

local folder 
```yaml
resources:
  - templates
```
remote target
```yaml
resources:
  - https://github.com/your-organisation/repository/templates/
```

For detailed information consult the [documentation](https://docs.airlock.com/microgateway/latest/#data/1668421864983.html).