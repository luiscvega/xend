XENDrb

A simple library to interact with Xend.ph's API.

Instructions:

```
  $ dep install
```

# Milestones

- Rate
  - Calculate
- Shipment
  - Get
  - Create
- Booking
  - ScheduleDev
- Tracking

# Questions

- Para saan ang waybill?
- COD - indicate special instructions? price?
- Can we pass in the waybill number in the remarks param for schedule dev?
- How does quantity affect the rate?

# Notes

- Kindly check zipcodes-v2.csv to see the updated list of locations with corresponding zone (There are only 5: Metro Manila, Rizal, Luzon, Visayas, Mindanao)
- When calculating ProvincialExpress rates using Xend's API, you must specify province in xml (i.e. province: "Abra"). The province string must identically match the province name in Xend's list in its API. (See Page 13 of docs).
- I have already fixed some conflicts between Xend's Locations list and Checkout.ph Locations list.
- Some discrepancies may arise (i.e. Xend: "Sorsogon", Checkout.ph: "Sorsogon Province")