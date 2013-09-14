    
    % Weighted regression is one of the abilities of lscov.
%    weights = weights / min(weights(weights~=0));
 %   coef    = lscov(M, y, weights);
  %  y_model = [1 x_test]*coef;
    
  
  
  
  
  %    weights    = dp_kernel_ep(X_train, x_test, lambda);

  
  
  
  
  

    % training
    %{
    DS.dataName     = 'houses';
    inputName       = {'lat','lon','sqft','appr','known_defects','defects_report','foundation_repair','defects_repaired','treated','lotsize','year','protest'};
    [DS.inputName]  = deal(inputName);
    [DS.outputName] = deal(outputName);
    DS.input        = T(:, 1:end-1)';
    DS.output       = T(:, end)';
    
    % test
    TS        = DS;
    TS.input  = S(:,1:end-1)';
    TS.output = S(:,end)';

    % run KNN
    computed     = knnr(DS, TS, k);
    confusionMat = getConfusionMat(TS.output, computed);
    confusionMatPlot(confusionMat, DS.outputName);
    %}
