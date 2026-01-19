table 50120 "Management Fee Calc. Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(50100; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(50101; "Report Date"; Date)
        {
            DataClassification = ToBeClassified;

        }

        field(50102; "Owner ID"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Owner Profile"."Owner ID";

            trigger OnValidate()
            begin
                CalcFields("Owner Name");
            end;

        }
        field(50103; "Owner Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Owner Profile"."Full Name" where("Owner ID" = field("Owner ID")));
        }
        field(50104; "Property"; Text[100])
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Property Registration"."Property Name" where("Owner ID" = Field("Owner ID"));
        }
        field(50105; "Financial Year"; Integer)
        {
            DataClassification = ToBeClassified;

            trigger OnLookup()
            var
                YearRec: Record Integer;
                integerList: Page "Integer List";
                CurrYear: Integer;
            begin
                CurrYear := Date2DMY(Today(), 3);

                YearRec.SetRange(Number, CurrYear - 5, CurrYear + 5);

                integerList.Caption := 'Select Financial Year';
                integerList.LookupMode(true);
                integerList.SetTableView(YearRec);
                if integerList.RunModal() = Action::LookupOK then begin
                    integerList.SetSelectionFilter(YearRec);
                    if YearRec.FindFirst() then
                        Rec."Financial Year" := YearRec.Number;
                    Rec."Period From" := 0D;
                    Rec."Period To" := 0D;
                end;
            end;
        }
        field(50106; "Period From"; Date)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                StartDate: Date;
                EndDate: Date;
            begin

                StartDate := DMY2Date(1, 1, Rec."Financial Year");
                EndDate := DMY2Date(31, 12, Rec."Financial Year");

                if (Rec."Period From" < StartDate) or (Rec."Period From" > EndDate) then
                    Error(
                      'Period From must be within Financial Year %1 (01/01/%1 - 31/12/%1).',
                      Rec."Financial Year");
            end;
        }
        field(50107; "Period To"; Date)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                StartDate: Date;
                EndDate: Date;
            begin
                StartDate := DMY2Date(1, 1, Rec."Financial Year");
                EndDate := DMY2Date(31, 12, Rec."Financial Year");

                if (Rec."Period To" < StartDate) or (Rec."Period To" > EndDate) then
                    Error(
                      'Period To must be within Financial Year %1 (01/01/%1 - 31/12/%1).',
                      Rec."Financial Year");

                if Rec."Period To" < Rec."Period From" then
                    Error('Period To cannot be earlier than Period From.');
            end;
        }
        field(50108; "All Owners"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50109; "All Properties"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    // trigger OnModify()
    // var
    // begin
    //     if "All Owners" = true then
    //         "All Properties" := true
    //     else
    //         "All Properties" := false;

    // end;


}