export const inGame = typeof GetParentResourceName === "function";

export async function fetchNui<T = unknown>(
  eventName: string,
  data: unknown = {},
): Promise<T | null> {
  if (!inGame) {
    return null;
  }

  const resourceName = GetParentResourceName();
  const response = await fetch(`https://${resourceName}/${eventName}`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(data),
  });

  return (await response.json()) as T;
}