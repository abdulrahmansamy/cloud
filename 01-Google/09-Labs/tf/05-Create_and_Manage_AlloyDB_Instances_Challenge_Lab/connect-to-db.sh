export ALLOYDB=10.109.0.8

echo $ALLOYDB  > alloydbip.txt 

export PGPASSWORD='Change3Me'
psql -h $ALLOYDB -U postgres
