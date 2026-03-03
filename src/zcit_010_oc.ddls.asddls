@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Request Item Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view entity ZCIT_010_OC
  as projection on ZCIT_010_O
{
  key LeaveID,
  key LeaveItemNo,

  LeaveDate,
  DayType,

  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt,

  _Header : redirected to parent ZCIT_010_C
}
