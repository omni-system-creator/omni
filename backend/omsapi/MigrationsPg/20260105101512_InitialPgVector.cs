using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.MigrationsPg
{
    /// <inheritdoc />
    public partial class InitialPgVector : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("Npgsql:PostgresExtension:vector", ",,");

            migrationBuilder.CreateTable(
                name: "kb_info",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Category = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_kb_info", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "kb_file",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    KbId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Size = table.Column<long>(type: "bigint", nullable: false),
                    Extension = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    Path = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    Status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    UploadTime = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsFolder = table.Column<bool>(type: "boolean", nullable: false),
                    ParentId = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_kb_file", x => x.Id);
                    table.ForeignKey(
                        name: "FK_kb_file_kb_file_ParentId",
                        column: x => x.ParentId,
                        principalTable: "kb_file",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_kb_file_kb_info_KbId",
                        column: x => x.KbId,
                        principalTable: "kb_info",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "sys_kb_node",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    KbId = table.Column<Guid>(type: "uuid", nullable: false),
                    ParentId = table.Column<Guid>(type: "uuid", nullable: true),
                    Title = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Summary = table.Column<string>(type: "text", nullable: true),
                    Content = table.Column<string>(type: "text", nullable: true),
                    Key = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    SortOrder = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_kb_node", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sys_kb_node_kb_info_KbId",
                        column: x => x.KbId,
                        principalTable: "kb_info",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_sys_kb_node_sys_kb_node_ParentId",
                        column: x => x.ParentId,
                        principalTable: "sys_kb_node",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "kb_node_source",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    NodeId = table.Column<Guid>(type: "uuid", nullable: false),
                    FileId = table.Column<Guid>(type: "uuid", nullable: false),
                    Page = table.Column<int>(type: "integer", nullable: false),
                    Description = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_kb_node_source", x => x.Id);
                    table.ForeignKey(
                        name: "FK_kb_node_source_kb_file_FileId",
                        column: x => x.FileId,
                        principalTable: "kb_file",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_kb_node_source_sys_kb_node_NodeId",
                        column: x => x.NodeId,
                        principalTable: "sys_kb_node",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_kb_file_KbId",
                table: "kb_file",
                column: "KbId");

            migrationBuilder.CreateIndex(
                name: "IX_kb_file_ParentId",
                table: "kb_file",
                column: "ParentId");

            migrationBuilder.CreateIndex(
                name: "IX_kb_node_source_FileId",
                table: "kb_node_source",
                column: "FileId");

            migrationBuilder.CreateIndex(
                name: "IX_kb_node_source_NodeId",
                table: "kb_node_source",
                column: "NodeId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_kb_node_KbId",
                table: "sys_kb_node",
                column: "KbId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_kb_node_ParentId",
                table: "sys_kb_node",
                column: "ParentId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "kb_node_source");

            migrationBuilder.DropTable(
                name: "kb_file");

            migrationBuilder.DropTable(
                name: "sys_kb_node");

            migrationBuilder.DropTable(
                name: "kb_info");
        }
    }
}
