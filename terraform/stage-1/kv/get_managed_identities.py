import sys
import json
from azure.identity import DefaultAzureCredential
from azure.mgmt.msi import ManagedServiceIdentityClient

def main():
    resource_group_name = sys.argv[1]
    
    credential = DefaultAzureCredential()
    client = ManagedServiceIdentityClient(credential, sys.argv[2])

    identities = client.user_assigned_identities.list_by_resource_group(resource_group_name)
    identity_names = [identity.name for identity in identities]

    print(json.dumps({"identity_names": ",".join(identity_names)}))

if __name__ == "__main__":
    main()
