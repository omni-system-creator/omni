using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations.SqlServer
{
    /// <inheritdoc />
    public partial class AddComments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "Type",
                table: "sys_chat_conversation",
                type: "int",
                nullable: false,
                comment: "0=Private, 1=Group, 2=System, 3=App",
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<long>(
                name: "RelatedId",
                table: "sys_chat_conversation",
                type: "bigint",
                nullable: true,
                comment: "关联ID。 对于群组(Type=1)，此处存GroupId。 对于系统/应用(Type=2/3)，如果模块有ID则存ID；如果只有字符串代码(如 \"workflow\")，则此处存null，通过 ConversationKey 区分。",
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "state",
                table: "bigview_project",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true,
                comment: "状态 [-1未发布,1发布]",
                oldClrType: typeof(string),
                oldType: "nvarchar(20)",
                oldMaxLength: 20,
                oldNullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "Type",
                table: "sys_chat_conversation",
                type: "int",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int",
                oldComment: "0=Private, 1=Group, 2=System, 3=App");

            migrationBuilder.AlterColumn<long>(
                name: "RelatedId",
                table: "sys_chat_conversation",
                type: "bigint",
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true,
                oldComment: "关联ID。 对于群组(Type=1)，此处存GroupId。 对于系统/应用(Type=2/3)，如果模块有ID则存ID；如果只有字符串代码(如 \"workflow\")，则此处存null，通过 ConversationKey 区分。");

            migrationBuilder.AlterColumn<string>(
                name: "state",
                table: "bigview_project",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(20)",
                oldMaxLength: 20,
                oldNullable: true,
                oldComment: "状态 [-1未发布,1发布]");
        }
    }
}
