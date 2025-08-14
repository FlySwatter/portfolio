import os, json, boto3

TABLE = os.environ.get("TABLE_NAME")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE)

def _resp(status, body):
    return {"statusCode": status, "body": json.dumps(body), "headers": {"Content-Type": "application/json"}}

def handler(event, context):
    route = event.get("requestContext", {}).get("http", {}).get("path", "/")
    method = event.get("requestContext", {}).get("http", {}).get("method", "GET")

    if method == "POST" and route.endswith("/todos"):
        item = json.loads(event.get("body") or "{}")
        if "id" not in item:
            return _resp(400, {"error": "id required"})
        table.put_item(Item=item)
        return _resp(201, item)

    if method == "GET" and route.startswith("/todos/"):
        todo_id = route.rsplit("/", 1)[-1]
        res = table.get_item(Key={"id": todo_id})
        if "Item" not in res:
            return _resp(404, {"error": "not found"})
        return _resp(200, res["Item"])

    return _resp(404, {"error": "route not found"})
