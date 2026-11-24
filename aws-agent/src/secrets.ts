import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";

const sm = new SecretsManagerClient({});
const cache = new Map<string, string>();

/** Read a secret once per Lambda container. Rotate by redeploying or letting the container recycle. */
export async function getSecret(secretId: string): Promise<string> {
  const hit = cache.get(secretId);
  if (hit !== undefined) return hit;
  const out = await sm.send(new GetSecretValueCommand({ SecretId: secretId }));
  if (!out.SecretString) throw new Error(`Secret ${secretId} has no string value`);
  cache.set(secretId, out.SecretString);
  return out.SecretString;
}
