table 50121 "Management Fee Calc. Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(50100; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(50101; "Header No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Header No.';
        }
        field(53102; "Vendor ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(53103; "Company/Owner Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(53104; "Property Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(53105; "Property Type"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(53106; "Calculation Method"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers =
                " ","Percentage of Monthly Revenue","Percentage of Annual Rent","Percentage of Collections","Per Unit Fee",Hybrid;
        }
        field(53107; "Calculation Sub-Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Percentage Based","Fixed Amount";
        }

        field(53108; "Percentage Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "",Fixed,Variable;
        }

        field(53109; "Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(53110; "Base Amount Source"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Revenue,Collections,"Annual Rent";
        }
        field(53111; "Base Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(53112; "Valid From"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(53113; "Valid To"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(53114; "Contract Status"; Option)
        {
            OptionMembers = Active,Expired;
            DataClassification = ToBeClassified;

        }

        field(53115; "Management Fee"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(53116; "Validity Period"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(53117; "Property Management Company"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(53118; Percentage; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(53119; "Owner ID"; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Header No.")
        {
            Clustered = true;
        }
    }

}