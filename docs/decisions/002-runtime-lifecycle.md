# Decision: separate desired runtime from restarts

## Context

Updating EC2 user data can replace or stop instances. A fleet-wide runtime change must not implicitly restart a controller majority or several brokers.

