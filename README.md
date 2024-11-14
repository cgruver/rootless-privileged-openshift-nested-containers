# rootless-privileged-openshift-nested-containers

1. Create an SCC for Podman:

   ```bash
   cat << EOF | oc apply -f -
   apiVersion: security.openshift.io/v1
   kind: SecurityContextConstraints
   metadata:
     name: rootless-podman-scc
   allowHostDirVolumePlugin: false
   allowHostIPC: false
   allowHostNetwork: false
   allowHostPID: false
   allowHostPorts: false
   allowPrivilegeEscalation: true
   allowPrivilegedContainer: true
   allowedCapabilities:
   - SETUID
   - SETGID
   fsGroup:
     type: MustRunAs
   groups: []
   readOnlyRootFilesystem: false
   runAsUser:
     type: MustRunAsRange
   seLinuxContext:
     type: MustRunAs
   supplementalGroups:
     type: RunAsAny
   users: []
   volumes:
   - configMap
   - downwardAPI
   - emptyDir
   - persistentVolumeClaim
   - projected
   - secret
   EOF
   ```

1. As cluster-admin allow a non-admin user to use the podman SCC

   ```bash
   oc adm policy add-scc-to-user rootless-podman-scc <non-admin-user>
   ```

1. Log into OpenShift as a non-admin user

1. Create a new Namespace:

   ```bash
   oc new-project podman-demo
   ```

1. Create a Pod:

   __Note:__ The image used in this Pod example is built from the `Containerfile` in this code repo.

   ```bash
   cat << EOF | oc apply -f -
   apiVersion: v1
   kind: Pod
   metadata:
     name: nested-podman
     namespace: podman-demo
   spec:
     containers:
     - name: nested-podman
       image: quay.io/cgruver0/rootless-nested-podman:latest
       securityContext:
         allowPrivilegeEscalation: true
         privileged: true
         capabilities:
           add:
           - "SETUID"
           - "SETGID"
   EOF
   ```

1. Open a shell into the Pod:

   ```bash
   oc rsh nested-podman
   ```

1. Run the following container:

   ```bash
   podman run -d --rm --name webserver -p 8080:80 quay.io/libpod/banner
   ```

1. Observe that the container is running and listening on port 8080:

   ```bash
   curl http://localhost:8080
   ```
