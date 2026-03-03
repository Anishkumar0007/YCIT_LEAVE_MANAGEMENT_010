@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Interface View for Leave Header'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZCIT_010_I
  as select from zcit_010_hdr as LeaveHeader

  /* Composition to the child item view */
  composition [0..*] of ZCIT_010_O as _LeaveItems

{
  key leave_id                     as LeaveID,

      employee_id                  as EmployeeID,
      leave_type                   as LeaveType,
      start_date                   as StartDate,
      end_date                     as EndDate,
      status                       as Status,
      
      

  /* Administrative Fields for ETag and Framework */

  @Semantics.user.createdBy: true
      local_created_by             as LocalCreatedBy,

  @Semantics.systemDateTime.createdAt: true
      local_created_at             as LocalCreatedAt,

  @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by        as LocalLastChangedBy,

  @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at        as LocalLastChangedAt,

  @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at              as LastChangedAt,

  /* Association exposure */
      _LeaveItems

}
