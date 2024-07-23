

## Create a topic called myTopic
```
gcloud pubsub topics create myTopic
```

## Create two more topics; one called `Test1` and the other called `Test2`

```
gcloud pubsub topics create Test1
gcloud pubsub topics create Test2
gcloud pubsub topics list
```

##  Delete Test1 and Test2
```
gcloud pubsub topics delete Test1
gcloud pubsub topics delete Test2

gcloud pubsub topics list
```

## create a subscription called mySubscription to topic myTopic

```
gcloud  pubsub subscriptions create --topic myTopic mySubscription
```

## Add another two subscriptions to myTopic
```
gcloud  pubsub subscriptions create --topic myTopic Test1
gcloud  pubsub subscriptions create --topic myTopic Test2

gcloud pubsub topics list-subscriptions myTopic
```

## Now delete the Test1 and Test2 subscriptions
```
gcloud pubsub subscriptions delete Test1
gcloud pubsub subscriptions delete Test2

gcloud pubsub topics list-subscriptions myTopic
```

## publish the message "hello" to `myTopic`
```
gcloud pubsub topics publish myTopic --message "Hello"
```

```
gcloud pubsub topics publish myTopic --message "Publisher's name is <YOUR NAME>"
gcloud pubsub topics publish myTopic --message "Publisher likes to eat <FOOD>"
gcloud pubsub topics publish myTopic --message "Publisher thinks Pub/Sub is awesome"
```

## pull the messages you just published
```
gcloud pubsub subscriptions pull mySubscription --auto-ack
```

## 
```
gcloud pubsub topics publish myTopic --message "Publisher is starting to get the hang of Pub/Sub"
gcloud pubsub topics publish myTopic --message "Publisher wonders if all messages will be pulled"
gcloud pubsub topics publish myTopic --message "Publisher will have to test to find out"
```

```
gcloud pubsub subscriptions pull mySubscription --auto-ack --limit=3
```
