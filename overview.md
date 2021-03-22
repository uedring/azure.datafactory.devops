# Validate Azure Data Factory code

Use it to validate the code of your Azure Data Factory before you publish it onto target ADF service. 
The function validates files of ADF in a given location, returning warnings or errors.  
The following validation will be perform:
- Reads all files and validates its json format
- Checks whether all dependant objects exist
- Checks whether file name equals object name
- (more soon...)


## Parameters:  
- `DataFactoryRoot` - Source folder where all ADF objects are kept. The folder should contain subfolders like pipeline, linkedservice, etc.
