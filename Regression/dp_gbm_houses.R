basedir = "C:\\Code\\Classes\\Comp540\\Code\\Regression"

dp_find_closest <- function(dtrain,testobs,n)
{
    dist   = sqrt((dtrain$lat-testobs$lat)^2 + (dtrain$lon-testobs$lon)^2)
    ddist  = data.frame(cbind(dist,dtrain))
    cat("size of ddist =",dim(ddist),"\n")
    str(ddist[1:5,])
    dsort  = ddist[sort.list(ddist$dist),]
    dsort[1:n,]
}

dp_gbm_local <- function(verbose)
{
    # read in the data
    dfile   = paste(basedir,"training_data.csv",sep="\\")
    draw    = read.table(dfile, sep=",", header=TRUE, row.names=NULL, check.names=TRUE)

    # shave off the id columns
    idcols = 1
    d      = draw[,(idcols+1):ncol(draw)]
    
    # split into a training and test set
    fractest = 0.10
    nobs     = nrow(d)
    numtrain = nobs*(1-fractest)
    train    = c(1:numtrain)
    dtrain   = d[train,]
    
    for (k in (numtrain+1):nobs)
    {
        #
        testobs = draw[k,]
    
        # grab the (physically) closest houses
        dclose = dp_find_closest(dtrain,testobs,30)
    
        # call our gbm routine
        dp_gbm(
            numtrees  = 400,
            learnrate = 0.1,
            treesize  = 6,
            fracheld  = 0.2,
            fracbag   = 0.8,
            numidcols = idcols,
            verbose   = TRUE,
            draw      = draw,
            dtrain    = dclose,
            dtest     = testobs[,(numidcols+1):ncol(p)],
            dtestraw  = testobs)
            
        readline()
    }
}

dp_gbm_global <- function(verbose)
{
    # read in the data
    dfile   = paste(basedir,"training_data.csv",sep="\\")
    draw    = read.table(dfile, sep=",", header=TRUE, row.names=NULL, check.names=TRUE)

    # shave off the id columns
    idcols = 1
    d      = draw[,(idcols+1):ncol(draw)]
	
    # normalize it
    d    = cbind(data.frame(scale(d[,1:(ncol(d)-1)],TRUE,TRUE)),salesprice=d$salesprice)
    draw = cbind(draw[,1:(idcols+1)],d)

    # split into a training and test set
    fractest = 0.10
    nobs     = nrow(d)
    train    = c(1:(nobs*(1-fractest)))
    dtrain   = d[train,]
    dtest    = d[-train,]
    
    # call our gbm routine
    dp_gbm(
        numtrees  = 400,
        learnrate = 0.1,
        treesize  = 6,
        fracheld  = 0.2,
        fracbag   = 0.8,
        numidcols = idcols,
        verbose   = TRUE,
        draw      = draw,
        dtrain    = dtrain,
        dtest     = dtest,
        dtestraw  = draw[-train,])
}


dp_gbm <- function(numtrees,learnrate,treesize,fracheld,fracbag,numidcols,verbose,draw,dtrain,dtest,dtestraw)
{

    # build the model using gbm
    f          <- as.formula("salesprice ~ .")
    gbm_houses <- gbm(
        f,                           # formula
        data=dtrain,                 # dataset
        distribution="laplace",      # distribution
        n.trees=numtrees,            # number of trees
        shrinkage=learnrate,         # shrinkage or learning rate, 0.001 to 0.1 usually work
        interaction.depth=treesize,  # 1: additive model, 2: two-way interactions, etc.
        bag.fraction=fracbag,        # subsampling fraction, 0.5 is probably best
        train.fraction=(1-fracheld), # fraction of data for training
        keep.data=TRUE,              # keep a copy of the dataset with the object
        verbose=FALSE)               # print out progress

    # check performance using a heldout test set
    best.iter <- gbm.perf(gbm_houses, method="test")

    # predict on the new data using "best" number of trees
    # f.predict generally will be on the canonical scale (logit,log,etc.)
    f.predict <- predict.gbm(gbm_houses,dtest,best.iter)

    # statistics
    error      = dtest$salesprice - f.predict
    percenterr = error / dtest$salesprice
    abspercent = abs(percenterr)
    testsize   = nrow(dtest)
    print(testsize)
    zerr       = abs((dtest$salesprice-(dtestraw$zestimate/100000))/dtest$salesprice)
    wewin      = abspercent<zerr
    under20    = sum(abspercent<0.2)/testsize
    under10    = sum(abspercent<0.1)/testsize
    under5     = sum(abspercent<0.05)/testsize
    
    if (verbose)
    {
        # plot the performance
        # plot variable influence
        # based on the estimated best number of trees
        summary(gbm_houses,n.trees=best.iter,cBars=10,order=TRUE) 

	  # compactly print the first and last trees for curiosity
	  print(pretty.gbm.tree(gbm_houses,1))
	  print(pretty.gbm.tree(gbm_houses,gbm_houses$n.trees))

        cat("Best_iter:\t",   best.iter,              "\n")
        cat("Sum_squared:\t", sum(error^2),           "\n")
        cat("Mean_err:\t",    mean(abspercent)*100,   "%\n")
        cat("Median_err:\t",  median(abspercent)*100, "%\n")
        cat("Max_err:\t",     max(abspercent)*100,    "%\n")
        cat("Below_20%:\t",   under20*100,            "%\n")
        cat("Below_10%:\t",   under10*100,            "%\n")
        cat("Below_5%:\t",    under5*100,             "%\n")

        # write out the results
        dtest[,ncol(dtest)] = dtest[,ncol(dtest)]
        f.predict           = f.predict
        results             = cbind(dtest$salesprice, f.predict, abspercent)
        outfile             = paste(basedir,"results.txt",sep="\\")
        write.table(results, file=outfile, sep=",", row.names=FALSE)
    }
    
    # return the parameters and results
    params  = c(numtrees,learnrate,treesize,fracbag)
    result  = c(best.iter,mean(abspercent),median(abspercent),max(abspercent),under20,under10,under5)
    c(params,result)
}

dp_gbm_param_search <- function(resultfile)
{
    k       = 0
    allruns = NULL
    for (t in seq(300,1200,by=100))
        for (l in c(0.01,0.1,0.5,1.0))
            for (s in 2:6)
                for (b in seq(0.1,1.0,by=0.1))
                {
                    run     = dp_gbm(numtrees=t,learnrate=l,treesize=s,fractest=0.2,fracheld=0.2,fracbag=b,numidcols=3,verbose=FALSE)
                    allruns = rbind(allruns, run)
                    k       = k+1
                    if ((k%%100) == 0)
                    {
                        cat("Iteration: ",k,"\n")
                    }
                }
    outfile = paste(basedir,resultfile,sep="\\")
    write.table(allruns, file=outfile, sep=",", row.names=FALSE)
}

dp_gbm_global(verbose=TRUE)
