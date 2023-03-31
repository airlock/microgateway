# Description
This folder contains the most basic example to get started with an almost empty `SidecarGateway` CR that will protect the `nginx` backend. The backend is defined in `examples/utilities/backends/nginx-protected`.

* Execute
    ```
    kubectl apply -k https://github.com/airlock/microgateway/examples/configurations/basic/
    ```
    to deploy the application.


* Perform a test call

    *Request*
    ```
    kubectl run test-caller --image=curlimages/curl --rm --restart=Never -i --tty --command -- curl -v "http://nginx:8080/"
    ```

    *Output*
    ```
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
    html { color-scheme: light dark; }
    body { width: 35em; margin: 0 auto;
    font-family: Tahoma, Verdana, Arial, sans-serif; }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>

    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>
    ```