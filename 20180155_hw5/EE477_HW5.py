#
#####################################################################################################################
"""                                  EE477 Database and Bigdata system  HW5                                        """
#######################################################################################################################
"""
   * pyspark rdd methods : https://spark.apache.org/docs/1.1.1/api/python/pyspark.rdd.RDD-class.html
"""
import sys
from pyspark.sql import SparkSession


def warmup_sql (spark, datafile):
   
    df = spark.read.parquet(datafile)
    df.createOrReplaceTempView("flights")
    rq = spark.sql("SELECT depdelay FROM flights LIMIT 100")
    
    rq.show()
    
    return rq

def warmup_rdd (spark, datafile):
   
    d = spark.read.parquet(datafile).rdd
    
    r = d.map(lambda x: x['depdelay'])   
    r = spark.sparkContext.parallelize(r.take(100)) # limit 100
    
    return r

def Q1 (spark, datafile):
    
    df = spark.read.parquet(datafile)
    
    # your code here
    df.createOrReplaceTempView("flights")
    rq = spark.sql("SELECT DISTINCT destcityname FROM flights WHERE origincityname = 'Seattle, WA'")
    rq.show()
    return rq

def Q2 (spark, datafile):
    
    d = spark.read.parquet(datafile).rdd
    r = d.map(lambda x: (x['destcityname'],x['origincityname']))
    r = r.filter(lambda w: w[1] == 'Seattle, WA').distinct()
    r = r.map(lambda w: w[0])
    # your code here
    
    return r
    
def Q3 (spark, datafile):
    
    d = spark.read.parquet(datafile).rdd
    r = d.filter(lambda x: x['cancelled'] == 0)
    r = r.map(lambda x: (x['origincityname'],x['month']))
    r = r.map(lambda x: (x,1)).groupByKey().mapValues(sum)
    # your code here
    return r


def Q4 (spark, datafile):
 
    d = spark.read.parquet(datafile).rdd
    r = d.map(lambda x: (x['destcityname'],x['origincityname'])).distinct()
    r = r.groupByKey().mapValues(len)
    maximum = r.max(key=lambda x:x[1])
    r = r.filter(lambda x: x[1] == maximum[1])
    # your code here
    
    return r



def Q5 (spark, datafile):
    
    d = spark.read.parquet(datafile).rdd
    r = d.filter(lambda x: x['depdelay'] != None)
    r = r.map(lambda x: (x['origincityname'],x['depdelay'])).groupByKey()
    r = r.map(lambda w: (w[0], sum(w[1])/len(w[1])))
    
    # your code here
    
    return r

if __name__ == '__main__':
    
    input_data = sys.argv[1]
    output = sys.argv[2]
    
    spark = SparkSession.builder.appName("HW5").getOrCreate()

    """ - WarmUp SQL - """
    #rq = warmup_sql(spark, input_data)
    #rq.rdd.repartition(1).saveAsTextFile(output)
    
    """ - WarmUp RDD - """
    #r = warmup_rdd(spark, input_data)
    #r.repartition(1).saveAsTextFile(output)
    
    """ - Problem 1 - """
    #rq1 = Q1(spark, input_data)
    #rq1.rdd.repartition(1).saveAsTextFile(output)
    
    """ - Problem 2 - """
    #r2 = Q2(spark, input_data)
    #r2.repartition(1).saveAsTextFile(output)
    
    """ - Problem 3 - """
    #r3 = Q3(spark, input_data)
    #r3.repartition(1).saveAsTextFile(output)
    
    """ - Problem 4 - """
    #r4 = Q4(spark, input_data)
    #r4.repartition(1).saveAsTextFile(output)
    
    """ - Problem 5 - """
    #r5 = Q5(spark, input_data)
    #r5.repartition(1).saveAsTextFile(output)

    spark.stop()
