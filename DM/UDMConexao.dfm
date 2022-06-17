object DMConexao: TDMConexao
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 233
  Width = 338
  object FDPhysMongoDriverLink1: TFDPhysMongoDriverLink
    Left = 88
    Top = 32
  end
  object FDConexao: TFDConnection
    Params.Strings = (
      'DriverID=Mongo'
      'Database=dbcompblinq'
      'POOL_MaximumItems=50')
    FetchOptions.AssignedValues = [evMode, evRowsetSize, evAutoFetchAll]
    FetchOptions.Mode = fmAll
    LoginPrompt = False
    Left = 88
    Top = 104
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 224
    Top = 32
  end
end
