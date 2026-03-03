@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Request Header Consumption View'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity ZCIT_010_C
  provider contract transactional_query
  as projection on ZCIT_010_I
{

  @Search.defaultSearchElement: true
  key LeaveID,

      EmployeeID,
      LeaveType,
      StartDate,
      EndDate,
      Status,

      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      _LeaveItems : redirected to composition child ZCIT_010_OC

}
