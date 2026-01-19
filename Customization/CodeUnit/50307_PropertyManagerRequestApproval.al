

// codeunit 50307 "Property Manager Approval"
// {


//     [EventSubscriber(ObjectType::Table, Database::"Tenancy Contract", 'OnAfterModifyEvent', '', false, false)]
//     local procedure OnAfterModifyTenancyContract(var Rec: Record "Tenancy Contract"; xRec: Record "Tenancy Contract"; RunTrigger: Boolean)
//     var
//         ApprovalStatusList: Record "Approval Contract Status";
//         EmailMessage: Codeunit "Email Message";
//         Email: Codeunit "Email";
//         UserPersonalizationRec: Record "User Personalization";
//         UserRec: Record User;
//         EmailList: List of [Text];
//         LeaseManagerName: Text;
//         CompanyInfo: Record "Company Information";
//         EmailBody: Text;
//     begin
//         if Rec."Update Contract Status" <> xRec."Update Contract Status" then begin
//             // Insert new record in Approval Request list
//             ApprovalStatusList.Init();
//             ApprovalStatusList."Contract ID" := Rec."Contract ID";
//             ApprovalStatusList.Status := 'Pending';
//             ApprovalStatusList."Renewal Contract ID" := 0;
//             ApprovalStatusList."Lease ID" := Rec."Created By";
//             ApprovalStatusList."Tenancy Contract Status" := GetTenancyStatusFromUpdateStatus(Format(Rec."Update Contract Status"));

//             ApprovalStatusList.Insert();

//             // Prepare email to Lease Managers
//             // EmailList.Clear();
//             LeaseManagerName := '';

//             UserPersonalizationRec.SetRange("Profile ID", 'PROPERTY MANAGER');
//             if UserPersonalizationRec.FindSet() then
//                 repeat
//                     if UserRec.Get(UserPersonalizationRec."User SID") then
//                         if UserRec."Contact Email" <> '' then begin
//                             EmailList.Add(UserRec."Contact Email");
//                             if LeaseManagerName = '' then
//                                 LeaseManagerName := UserRec."User Name"
//                             else
//                                 LeaseManagerName += ', ' + UserRec."User Name";
//                         end;
//                 until UserPersonalizationRec.Next() = 0;

//             if EmailList.Count = 0 then
//                 Error('No valid email addresses found for PROPERTY MANAGER.');

//             if CompanyInfo.Get() then begin
//                 EmailBody :=
//                         '<html><body>' +
//                         '<p>Dear Property Manager,</p>' +
//                         '<p>This is an automated notification from the system.</p>' +
//                         '<p>A recent update has been made to the tenancy contract with <b>Contract ID -' + Format(Rec."Contract ID") + '</b>.</p>' +
//                         '<p>Please review the <b>Approval Contract Status List</b> and take the necessary action as required.</p>' +
//                         '<p>To proceed, please log in to the system and review the pending status under the <b>Approval Contract Status List</b> section.</p>' +
//                         '<p>This is a system-generated email. Please do not reply to this message.</p>' +
//                         '<p>Thank you,</p>' +
//                         '</body></html>';

//                 EmailMessage.Create(
//                     EmailList,
//                     'System Notification: Action Required - Review Approval Contract Status For Activation - Contract ID - ' + Format(Rec."Contract ID"),
//                     EmailBody,
//                     true
//                 );

//                 if not Email.Send(EmailMessage) then
//                     Error('Email failed to send. Please check SMTP settings.');
//             end;
//         end;
//     end;

//     local procedure GetTenancyStatusFromUpdateStatus(UpdateStatus: Text): Text
//     begin
//         case UpdateStatus of
//             'Initiate Activation Process':
//                 exit('Activation');
//             'Initiate Termination Process':
//                 exit('Termination');
//             'Initiate Suspension Process':
//                 exit('Suspension');
//             'Initiate Under Suspension-Unit Released':
//                 exit('Suspended-Unit Released');
//             else
//                 exit('Unknown');
//         end;
//     end;
// }


codeunit 50307 "Property Manager Approval"
{
    // Public method to update contract status with trigger logic
    procedure UpdateContractStatus(var Rec: Record "Tenancy Contract"; NewStatus: Option)
    var
        xRec: Record "Tenancy Contract";
    begin
        xRec := Rec;
        if Rec."Update Contract Status" <> NewStatus then begin
            Rec."Update Contract Status" := NewStatus;
            Rec.Modify(true); // Ensure OnAfterModifyEvent is triggered
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tenancy Contract", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyTenancyContract(var Rec: Record "Tenancy Contract"; xRec: Record "Tenancy Contract"; RunTrigger: Boolean)
    begin
        if Rec."Update Contract Status" <> xRec."Update Contract Status" then
            HandleContractStatusUpdate(Rec);
    end;

    procedure HandleContractStatusUpdate(Rec: Record "Tenancy Contract")
    var
        ApprovalStatusList: Record "Approval Contract Status";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit "Email";
        UserPersonalizationRec: Record "User Personalization";
        UserRec: Record User;
        EmailList: List of [Text];
        LeaseManagerName: Text;
        CompanyInfo: Record "Company Information";
        EmailBody: Text;
        EmailSubject: Text;
        StatusText: Text;
    begin
        // Prevent duplicate approval entry
        // if ApprovalStatusList.Get(Rec."Contract ID") then
        //     exit;

        // Determine status from Update Contract Status text
        StatusText := GetTenancyStatusFromUpdateStatus(Format(Rec."Update Contract Status"));

        // Insert record in Approval Status List
        ApprovalStatusList.Init();
        ApprovalStatusList."Contract ID" := Rec."Contract ID";
        ApprovalStatusList.Status := 'Pending';
        ApprovalStatusList."Renewal Contract ID" := 0;
        ApprovalStatusList."Lease ID" := Rec."Created By";
        ApprovalStatusList."Tenancy Contract Status" := StatusText;
        ApprovalStatusList.Insert();

        // Get Property Manager emails
        LeaseManagerName := '';
        UserPersonalizationRec.SetRange("Profile ID", 'PROPERTY MANAGER');
        if UserPersonalizationRec.FindSet() then
            repeat
                if UserRec.Get(UserPersonalizationRec."User SID") then
                    if UserRec."Contact Email" <> '' then begin
                        EmailList.Add(UserRec."Contact Email");
                        if LeaseManagerName = '' then
                            LeaseManagerName := UserRec."User Name"
                        else
                            LeaseManagerName += ', ' + UserRec."User Name";
                    end;
            until UserPersonalizationRec.Next() = 0;

        if EmailList.Count = 0 then
            Error('No valid email addresses found for PROPERTY MANAGER.');

        if CompanyInfo.Get() then begin
            // Use subject based on status
            case StatusText of
                'Activation':
                    EmailSubject := 'Review Approval Contract Status For Activation - Contract ID - ' + Format(Rec."Contract ID");
                'Termination':
                    EmailSubject := 'Review Approval Contract Status For Termination - Contract ID - ' + Format(Rec."Contract ID");
                'Suspension':
                    EmailSubject := 'Review Approval Contract Status For Suspension - Contract ID - ' + Format(Rec."Contract ID");
                'Suspended-Unit Released':
                    EmailSubject := 'Review Approval Contract Status For Suspension - Contract ID - ' + Format(Rec."Contract ID");
                else
                    EmailSubject := 'Review Approval Contract Status - Contract ID - ' + Format(Rec."Contract ID");
            end;

            // Shared email body format
            EmailBody :=
                '<html><body>' +
                '<p>Dear Property Manager,</p>' +
                '<p>This is an automated notification from the system.</p>' +
                '<p>A recent update has been made to the tenancy contract with <b>Contract ID: ' + Format(Rec."Contract ID") + '</b>.</p>' +
                '<p>Please review the <b>Approval Contract Status List</b> and take the necessary action as required.</p>' +
                '<p>To proceed, please log in to the system and review the pending status under the <b>Approval Contract Status List</b> section.</p>' +
                '<p>This is a system-generated email. Please do not reply to this message.</p>' +
                '<p>Thank you,</p>' +
                '</body></html>';

            EmailMessage.Create(
                EmailList,
                EmailSubject,
                EmailBody,
                true
            );

            if not Email.Send(EmailMessage) then
                Error('Email failed to send. Please check SMTP settings.');
        end;
    end;

    local procedure GetTenancyStatusFromUpdateStatus(UpdateStatus: Text): Text
    begin
        case UpdateStatus of
            'Initiate Activation Process':
                exit('Activation');
            'Initiate Termination Process':
                exit('Termination');
            'Initiate Suspension Process':
                exit('Suspension');
            'Initiate Under Suspension-Unit Released':
                exit('Suspended-Unit Released');
            else
                exit('Unknown');
        end;
    end;
}
