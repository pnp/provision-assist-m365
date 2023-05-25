# Cost Estimates

## Assumptions

The estimate below assumes:

- 500 users in the tenant

- Provisioning Logic App runs every hour (to create collaboration spaces for all approved requests)

- Verify availability hits every time when the user creates the request, once per user per space.

## SKU recommendations

The recommended SKUs for a production environment are:

- Logic Apps
- API Connections
- Automation Account
- Azure Runbooks

## Estimated load

**Number of Space requests**: 500 users * 1 request/user/month = 500 request/month

## Estimated cost
**IMPORTANT:**  This is only an estimate, based on the assumptions above. Your actual costs may vary.

Prices were taken from the  [Pricing](https://azure.microsoft.com/en-us/pricing/) on 06 May 2020, for the West US region.

Use the  [Azure Pricing Calculator](https://azure.com/e/37608b74af8a4e57bc5834321c2a2c23) to model different service tiers and usage patterns.

| Resource | Tier |Load|Monthly price|
|--|--|--|--
| Azure Logic Apps | N/A | 1 action execution/day |$0.01|
| Azure Automation | Process automation capability | 500 minutes of process automation and 744 hours of watchers are free each month. Charges applied only if free quote is consumed |$1.46|
|Total| | | $1.47|
