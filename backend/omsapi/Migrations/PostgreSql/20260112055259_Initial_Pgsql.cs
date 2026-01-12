using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace omsapi.Migrations.PostgreSql
{
    /// <inheritdoc />
    public partial class Initial_Pgsql : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "api_category",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    UrlPrefix = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    ParentId = table.Column<long>(type: "bigint", nullable: true),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_api_category", x => x.Id);
                    table.ForeignKey(
                        name: "FK_api_category_api_category_ParentId",
                        column: x => x.ParentId,
                        principalTable: "api_category",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "arch_fond",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_arch_fond", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "arch_type",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ParentId = table.Column<long>(type: "bigint", nullable: true),
                    Code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    SortOrder = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_arch_type", x => x.Id);
                    table.ForeignKey(
                        name: "FK_arch_type_arch_type_ParentId",
                        column: x => x.ParentId,
                        principalTable: "arch_type",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "bigview_project",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    project_name = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    state = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    create_time = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    create_by = table.Column<string>(type: "text", nullable: true),
                    is_delete = table.Column<string>(type: "character varying(1)", maxLength: 1, nullable: true),
                    index_image = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    content = table.Column<string>(type: "text", nullable: true),
                    remarks = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_bigview_project", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "contract_knowledge_category",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    parent_id = table.Column<long>(type: "bigint", nullable: true),
                    sort_order = table.Column<int>(type: "integer", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contract_knowledge_category", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "contract_knowledge_file",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    category_id = table.Column<long>(type: "bigint", nullable: false),
                    name = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    content_type = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    file_path = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    size = table.Column<long>(type: "bigint", nullable: false),
                    uploader = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    upload_time = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contract_knowledge_file", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "contract_main",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    contract_no = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    contract_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    partner_name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    sign_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    start_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    end_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    manager = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    total_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    paid_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    invoiced_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    progress = table.Column<int>(type: "integer", nullable: false),
                    currency = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    payment_method = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    tax_id = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    description = table.Column<string>(type: "text", nullable: true),
                    latest_transaction_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    files = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contract_main", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "contract_stat",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    period_type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    period_key = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    stat_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    total_contracts = table.Column<int>(type: "integer", nullable: false),
                    total_contracts_growth = table.Column<decimal>(type: "numeric(5,2)", nullable: false),
                    amount_completion_rate = table.Column<decimal>(type: "numeric(5,2)", nullable: false),
                    received_rate = table.Column<decimal>(type: "numeric(5,2)", nullable: false),
                    total_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    received_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    invoiced_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    pending_invoice_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    sales_count = table.Column<int>(type: "integer", nullable: false),
                    purchase_count = table.Column<int>(type: "integer", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contract_stat", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "contract_template",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    description = table.Column<string>(type: "text", nullable: true),
                    file_path = table.Column<string>(type: "text", nullable: true),
                    file_name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contract_template", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "data_source_connection",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Host = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Port = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    User = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Password = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Database = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_data_source_connection", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "frm_category",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    ParentId = table.Column<long>(type: "bigint", nullable: true),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_frm_category", x => x.Id);
                    table.ForeignKey(
                        name: "FK_frm_category_frm_category_ParentId",
                        column: x => x.ParentId,
                        principalTable: "frm_category",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "frm_data",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    form_id = table.Column<long>(type: "bigint", nullable: false),
                    data = table.Column<string>(type: "text", nullable: false),
                    submitted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    submitted_by = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_frm_data", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "kb_info",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Category = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_kb_info", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "page_categories",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    ParentId = table.Column<long>(type: "bigint", nullable: true),
                    SortOrder = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_page_categories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_page_categories_page_categories_ParentId",
                        column: x => x.ParentId,
                        principalTable: "page_categories",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "project_attachments",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    taskId = table.Column<string>(type: "text", nullable: false),
                    project_code = table.Column<string>(type: "text", nullable: false),
                    name = table.Column<string>(type: "text", nullable: true),
                    url = table.Column<string>(type: "text", nullable: true),
                    type = table.Column<string>(type: "text", nullable: true),
                    uploadDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_attachments", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "project_info",
                columns: table => new
                {
                    code = table.Column<string>(type: "text", nullable: false),
                    name = table.Column<string>(type: "text", nullable: true),
                    type = table.Column<string>(type: "text", nullable: true),
                    description = table.Column<string>(type: "text", nullable: true),
                    manager = table.Column<string>(type: "text", nullable: true),
                    planned_start_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    planned_end_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_info", x => x.code);
                });

            migrationBuilder.CreateTable(
                name: "project_phases",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    project_code = table.Column<string>(type: "text", nullable: false),
                    name = table.Column<string>(type: "text", nullable: true),
                    color = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_phases", x => new { x.id, x.project_code });
                });

            migrationBuilder.CreateTable(
                name: "project_swimlanes",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    project_code = table.Column<string>(type: "text", nullable: false),
                    name = table.Column<string>(type: "text", nullable: true),
                    color = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_swimlanes", x => new { x.id, x.project_code });
                });

            migrationBuilder.CreateTable(
                name: "project_task_dependencies",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    taskId = table.Column<string>(type: "text", nullable: false),
                    dependencyId = table.Column<string>(type: "text", nullable: false),
                    project_code = table.Column<string>(type: "text", nullable: false),
                    type = table.Column<string>(type: "text", nullable: true),
                    sourcePort = table.Column<string>(type: "text", nullable: true),
                    targetPort = table.Column<string>(type: "text", nullable: true),
                    controlPoints = table.Column<string>(type: "text", nullable: true),
                    controlPointCount = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_task_dependencies", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "project_tasks",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    project_code = table.Column<string>(type: "text", nullable: false),
                    name = table.Column<string>(type: "text", nullable: true),
                    phaseId = table.Column<string>(type: "text", nullable: true),
                    swimlaneId = table.Column<string>(type: "text", nullable: true),
                    status = table.Column<string>(type: "text", nullable: true),
                    progress = table.Column<int>(type: "integer", nullable: false),
                    owner = table.Column<string>(type: "text", nullable: true),
                    startDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    endDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    type = table.Column<string>(type: "text", nullable: true),
                    description = table.Column<string>(type: "text", nullable: true),
                    x = table.Column<float>(type: "real", nullable: false),
                    y = table.Column<float>(type: "real", nullable: false),
                    width = table.Column<float>(type: "real", nullable: false),
                    startColor = table.Column<string>(type: "text", nullable: true),
                    endColor = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_tasks", x => new { x.id, x.project_code });
                });

            migrationBuilder.CreateTable(
                name: "sales_bid_analysis",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    bid_project_id = table.Column<string>(type: "text", nullable: false),
                    tender_type = table.Column<string>(type: "text", nullable: false),
                    file_name = table.Column<string>(type: "text", nullable: true),
                    file_url = table.Column<string>(type: "text", nullable: true),
                    deadline = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    bid_bond = table.Column<string>(type: "text", nullable: true),
                    budget = table.Column<string>(type: "text", nullable: true),
                    bid_start_time = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    bid_end_time = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    tender_start_time = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    open_bid_time = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    publish_time = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    contact_name = table.Column<string>(type: "text", nullable: true),
                    contact_phone = table.Column<string>(type: "text", nullable: true),
                    agency_name = table.Column<string>(type: "text", nullable: true),
                    qualification = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_bid_analysis", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sales_bid_analysis_log",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    run_id = table.Column<long>(type: "bigint", nullable: false),
                    bid_project_id = table.Column<string>(type: "text", nullable: false),
                    message = table.Column<string>(type: "text", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_bid_analysis_log", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sales_bid_analysis_run",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    bid_project_id = table.Column<string>(type: "text", nullable: false),
                    status = table.Column<string>(type: "text", nullable: false),
                    started_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    finished_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    created_by = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_bid_analysis_run", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sales_bid_project",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    customer = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    region = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    budget = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    bid_time = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    leader = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    description = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_bid_project", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sales_customer",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    industry = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    contact = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    phone = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    email = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    level = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    address = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    source = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    description = table.Column<string>(type: "text", nullable: false),
                    owner = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_customer", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sales_opportunity",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    customer = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    customer_id = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    amount = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: false),
                    stage = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    win_rate = table.Column<int>(type: "integer", nullable: false),
                    owner = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    description = table.Column<string>(type: "text", nullable: false),
                    estimated_close_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_opportunity", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sales_process_rule",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    content = table.Column<string>(type: "text", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_process_rule", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sales_product_doc",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    size = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    url = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    parent_id = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    upload_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_product_doc", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sales_registrations",
                columns: table => new
                {
                    Id = table.Column<string>(type: "text", nullable: false),
                    ProjectName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    CustomerName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Contact = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Phone = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Amount = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: false),
                    Date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    Owner = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Remarks = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_registrations", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "sales_script",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    content = table.Column<string>(type: "text", nullable: false),
                    category = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_script", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sales_target",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    period = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    target_type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    target_id = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    target_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    target_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    completed_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    start_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    end_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_target", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sys_audit_log",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<long>(type: "bigint", nullable: true),
                    UserName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Action = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Route = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Method = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    IpAddress = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    UserAgent = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Parameters = table.Column<string>(type: "text", nullable: true),
                    IsSuccess = table.Column<bool>(type: "boolean", nullable: false),
                    ErrorMessage = table.Column<string>(type: "text", nullable: true),
                    ExecutionDuration = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_audit_log", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "sys_chat_conversation",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ConversationKey = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Type = table.Column<int>(type: "integer", nullable: false),
                    User1Id = table.Column<long>(type: "bigint", nullable: true),
                    User2Id = table.Column<long>(type: "bigint", nullable: true),
                    RelatedId = table.Column<long>(type: "bigint", nullable: true),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Avatar = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    LastMessageContent = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    LastMessageType = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    LastMessageTime = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_chat_conversation", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "sys_chat_message",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ConversationKey = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    SenderConnectionId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    SenderUserId = table.Column<long>(type: "bigint", nullable: true),
                    SenderUserName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Content = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    FileName = table.Column<string>(type: "text", nullable: true),
                    FileSize = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_chat_message", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "sys_config",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Category = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Key = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Type = table.Column<int>(type: "integer", nullable: false),
                    Value = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Description = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    IsSystem = table.Column<bool>(type: "boolean", nullable: false),
                    OrgId = table.Column<long>(type: "bigint", nullable: true),
                    IsOverridable = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_config", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "sys_dept",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ParentId = table.Column<long>(type: "bigint", nullable: true),
                    Name = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Type = table.Column<int>(type: "integer", nullable: false),
                    Leader = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Phone = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    Email = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    X = table.Column<double>(type: "double precision", nullable: true),
                    Y = table.Column<double>(type: "double precision", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_dept", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sys_dept_sys_dept_ParentId",
                        column: x => x.ParentId,
                        principalTable: "sys_dept",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "sys_dict_category",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    parent_id = table.Column<long>(type: "bigint", nullable: true),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    code = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    sort = table.Column<int>(type: "integer", nullable: false),
                    remark = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_dict_category", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sys_dict_category_sys_dict_category_parent_id",
                        column: x => x.parent_id,
                        principalTable: "sys_dict_category",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "sys_org_registration",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    OrgName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    OrgShortName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    OrgAbbr = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    LicenseCode = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    LicenseFileUrl = table.Column<string>(type: "text", nullable: true),
                    AuthLetterFileUrl = table.Column<string>(type: "text", nullable: true),
                    ContactName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    ContactPhone = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    ContactEmail = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    AdminUsername = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    AdminPassword = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    RejectReason = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_org_registration", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "sys_permission",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ParentId = table.Column<long>(type: "bigint", nullable: true),
                    Name = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Code = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Path = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Component = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Query = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    Icon = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    IsVisible = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_permission", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "sys_role_permission",
                columns: table => new
                {
                    RoleId = table.Column<long>(type: "bigint", nullable: false),
                    PermissionId = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_role_permission", x => new { x.RoleId, x.PermissionId });
                });

            migrationBuilder.CreateTable(
                name: "api_definition",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CategoryId = table.Column<long>(type: "bigint", nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Path = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Method = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    Description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    ViewRoles = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    CallRoles = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    ManageRoles = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    FlowConfig = table.Column<string>(type: "text", nullable: true),
                    IsPublished = table.Column<bool>(type: "boolean", nullable: false),
                    RequiresAuth = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<long>(type: "bigint", nullable: true),
                    UpdatedBy = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_api_definition", x => x.Id);
                    table.ForeignKey(
                        name: "FK_api_definition_api_category_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "api_category",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "arch_box",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FondId = table.Column<long>(type: "bigint", nullable: false),
                    TypeId = table.Column<long>(type: "bigint", nullable: false),
                    BoxCode = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Title = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Year = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    RetentionPeriod = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    SecurityLevel = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    Location = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    RFID = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    FileCount = table.Column<int>(type: "integer", nullable: false),
                    Remark = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_arch_box", x => x.Id);
                    table.ForeignKey(
                        name: "FK_arch_box_arch_fond_FondId",
                        column: x => x.FondId,
                        principalTable: "arch_fond",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_arch_box_arch_type_TypeId",
                        column: x => x.TypeId,
                        principalTable: "arch_type",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "contract_attachment",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    contract_id = table.Column<long>(type: "bigint", nullable: false),
                    file_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    file_path = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    size = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    upload_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contract_attachment", x => x.Id);
                    table.ForeignKey(
                        name: "FK_contract_attachment_contract_main_contract_id",
                        column: x => x.contract_id,
                        principalTable: "contract_main",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "contract_contact",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    contract_id = table.Column<long>(type: "bigint", nullable: false),
                    name = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    role = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    phone = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    email = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contract_contact", x => x.Id);
                    table.ForeignKey(
                        name: "FK_contract_contact_contract_main_contract_id",
                        column: x => x.contract_id,
                        principalTable: "contract_main",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "contract_invoice",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    contract_id = table.Column<long>(type: "bigint", nullable: false),
                    invoice_no = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    invoice_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contract_invoice", x => x.Id);
                    table.ForeignKey(
                        name: "FK_contract_invoice_contract_main_contract_id",
                        column: x => x.contract_id,
                        principalTable: "contract_main",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "contract_payment_plan",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    contract_id = table.Column<long>(type: "bigint", nullable: false),
                    phase = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    due_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    condition = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contract_payment_plan", x => x.Id);
                    table.ForeignKey(
                        name: "FK_contract_payment_plan_contract_main_contract_id",
                        column: x => x.contract_id,
                        principalTable: "contract_main",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "contract_payment_record",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    contract_id = table.Column<long>(type: "bigint", nullable: false),
                    payment_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    method = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    @operator = table.Column<string>(name: "operator", type: "character varying(50)", maxLength: 50, nullable: true),
                    remark = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contract_payment_record", x => x.Id);
                    table.ForeignKey(
                        name: "FK_contract_payment_record_contract_main_contract_id",
                        column: x => x.contract_id,
                        principalTable: "contract_main",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "frm_definition",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CategoryId = table.Column<long>(type: "bigint", nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    FormItems = table.Column<string>(type: "text", nullable: true),
                    IsPublished = table.Column<bool>(type: "boolean", nullable: false),
                    RequiresLogin = table.Column<bool>(type: "boolean", nullable: false),
                    LimitOnePerUser = table.Column<bool>(type: "boolean", nullable: false),
                    ViewRoleIds = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    FillRoleIds = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    ManageRoleIds = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<long>(type: "bigint", nullable: true),
                    UpdatedBy = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_frm_definition", x => x.Id);
                    table.ForeignKey(
                        name: "FK_frm_definition_frm_category_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "frm_category",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
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
                name: "kb_qa_history",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    KbId = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: true),
                    Question = table.Column<string>(type: "text", nullable: false),
                    Answer = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    SourcesJson = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_kb_qa_history", x => x.Id);
                    table.ForeignKey(
                        name: "FK_kb_qa_history_kb_info_KbId",
                        column: x => x.KbId,
                        principalTable: "kb_info",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "page_definitions",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    CategoryId = table.Column<long>(type: "bigint", nullable: true),
                    Code = table.Column<string>(type: "text", nullable: true),
                    Config = table.Column<string>(type: "text", nullable: true),
                    ApiBindings = table.Column<string>(type: "text", nullable: true),
                    Description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_page_definitions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_page_definitions_page_categories_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "page_categories",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "sales_bid_chapter",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    analysis_id = table.Column<long>(type: "bigint", nullable: false),
                    parent_id = table.Column<long>(type: "bigint", nullable: true),
                    title = table.Column<string>(type: "text", nullable: false),
                    chapter_type = table.Column<string>(type: "text", nullable: true),
                    content = table.Column<string>(type: "text", nullable: true),
                    analysis_result = table.Column<string>(type: "text", nullable: true),
                    risk_level = table.Column<string>(type: "text", nullable: true),
                    is_veto = table.Column<bool>(type: "boolean", nullable: false),
                    score_weight = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: true),
                    sort_order = table.Column<int>(type: "integer", nullable: false),
                    extractions_json = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sales_bid_chapter", x => x.id);
                    table.ForeignKey(
                        name: "FK_sales_bid_chapter_sales_bid_analysis_analysis_id",
                        column: x => x.analysis_id,
                        principalTable: "sales_bid_analysis",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_sales_bid_chapter_sales_bid_chapter_parent_id",
                        column: x => x.parent_id,
                        principalTable: "sales_bid_chapter",
                        principalColumn: "id");
                });

            migrationBuilder.CreateTable(
                name: "sys_post",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    Remark = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    DeptId = table.Column<long>(type: "bigint", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_post", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sys_post_sys_dept_DeptId",
                        column: x => x.DeptId,
                        principalTable: "sys_dept",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "sys_role",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    IsSystem = table.Column<bool>(type: "boolean", nullable: false),
                    DeptId = table.Column<long>(type: "bigint", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_role", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sys_role_sys_dept_DeptId",
                        column: x => x.DeptId,
                        principalTable: "sys_dept",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "sys_user",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Username = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Password = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Nickname = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Email = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Phone = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    Avatar = table.Column<string>(type: "text", nullable: true),
                    Status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastLoginAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    DeptId = table.Column<long>(type: "bigint", nullable: true),
                    CurrentOrgId = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_user", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sys_user_sys_dept_DeptId",
                        column: x => x.DeptId,
                        principalTable: "sys_dept",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "sys_dict_type",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    category_id = table.Column<long>(type: "bigint", nullable: true),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    code = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    remark = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_dict_type", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sys_dict_type_sys_dict_category_category_id",
                        column: x => x.category_id,
                        principalTable: "sys_dict_category",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "arch_file",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FondId = table.Column<long>(type: "bigint", nullable: false),
                    TypeId = table.Column<long>(type: "bigint", nullable: false),
                    BoxId = table.Column<long>(type: "bigint", nullable: true),
                    ArchCode = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Title = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    DocNumber = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Author = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    FileDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Year = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    RetentionPeriod = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    SecurityLevel = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    PageCount = table.Column<int>(type: "integer", nullable: false),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    Keywords = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Remark = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    SourceFileId = table.Column<long>(type: "bigint", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_arch_file", x => x.Id);
                    table.ForeignKey(
                        name: "FK_arch_file_arch_box_BoxId",
                        column: x => x.BoxId,
                        principalTable: "arch_box",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_arch_file_arch_fond_FondId",
                        column: x => x.FondId,
                        principalTable: "arch_fond",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_arch_file_arch_type_TypeId",
                        column: x => x.TypeId,
                        principalTable: "arch_type",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
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
                });

            migrationBuilder.CreateTable(
                name: "sys_role_inheritance",
                columns: table => new
                {
                    ParentRoleId = table.Column<long>(type: "bigint", nullable: false),
                    ChildRoleId = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_role_inheritance", x => new { x.ParentRoleId, x.ChildRoleId });
                    table.ForeignKey(
                        name: "FK_sys_role_inheritance_sys_role_ChildRoleId",
                        column: x => x.ChildRoleId,
                        principalTable: "sys_role",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_sys_role_inheritance_sys_role_ParentRoleId",
                        column: x => x.ParentRoleId,
                        principalTable: "sys_role",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "sys_file",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Extension = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    Size = table.Column<long>(type: "bigint", nullable: false),
                    IsFolder = table.Column<bool>(type: "boolean", nullable: false),
                    FilePath = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    ContentType = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    ParentId = table.Column<long>(type: "bigint", nullable: true),
                    OwnerId = table.Column<long>(type: "bigint", nullable: false),
                    DeptId = table.Column<long>(type: "bigint", nullable: true),
                    IsPublic = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_file", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sys_file_sys_dept_DeptId",
                        column: x => x.DeptId,
                        principalTable: "sys_dept",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_sys_file_sys_file_ParentId",
                        column: x => x.ParentId,
                        principalTable: "sys_file",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_sys_file_sys_user_OwnerId",
                        column: x => x.OwnerId,
                        principalTable: "sys_user",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "sys_user_post",
                columns: table => new
                {
                    UserId = table.Column<long>(type: "bigint", nullable: false),
                    PostId = table.Column<long>(type: "bigint", nullable: false),
                    DeptId = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_user_post", x => new { x.UserId, x.PostId, x.DeptId });
                    table.ForeignKey(
                        name: "FK_sys_user_post_sys_dept_DeptId",
                        column: x => x.DeptId,
                        principalTable: "sys_dept",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_sys_user_post_sys_post_PostId",
                        column: x => x.PostId,
                        principalTable: "sys_post",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_sys_user_post_sys_user_UserId",
                        column: x => x.UserId,
                        principalTable: "sys_user",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "sys_user_role",
                columns: table => new
                {
                    UserId = table.Column<long>(type: "bigint", nullable: false),
                    RoleId = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_user_role", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_sys_user_role_sys_role_RoleId",
                        column: x => x.RoleId,
                        principalTable: "sys_role",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_sys_user_role_sys_user_UserId",
                        column: x => x.UserId,
                        principalTable: "sys_user",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "sys_dict_data",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    dict_type_id = table.Column<long>(type: "bigint", nullable: false),
                    label = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    value = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    sort = table.Column<int>(type: "integer", nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    is_default = table.Column<bool>(type: "boolean", nullable: false),
                    css_class = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    list_class = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    remark = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_dict_data", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sys_dict_data_sys_dict_type_dict_type_id",
                        column: x => x.dict_type_id,
                        principalTable: "sys_dict_type",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "arch_attachment",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ArchFileId = table.Column<long>(type: "bigint", nullable: false),
                    FileId = table.Column<long>(type: "bigint", nullable: true),
                    FileName = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Extension = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    Size = table.Column<long>(type: "bigint", nullable: false),
                    FilePath = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_arch_attachment", x => x.Id);
                    table.ForeignKey(
                        name: "FK_arch_attachment_arch_file_ArchFileId",
                        column: x => x.ArchFileId,
                        principalTable: "arch_file",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_arch_attachment_sys_file_FileId",
                        column: x => x.FileId,
                        principalTable: "sys_file",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "sys_file_share",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FileId = table.Column<long>(type: "bigint", nullable: false),
                    SharedByUserId = table.Column<long>(type: "bigint", nullable: false),
                    SharedToUserId = table.Column<long>(type: "bigint", nullable: true),
                    Permission = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Token = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    ExpirationTime = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_file_share", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sys_file_share_sys_file_FileId",
                        column: x => x.FileId,
                        principalTable: "sys_file",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_sys_file_share_sys_user_SharedByUserId",
                        column: x => x.SharedByUserId,
                        principalTable: "sys_user",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_sys_file_share_sys_user_SharedToUserId",
                        column: x => x.SharedToUserId,
                        principalTable: "sys_user",
                        principalColumn: "Id");
                });

            migrationBuilder.InsertData(
                table: "sys_config",
                columns: new[] { "Id", "Category", "CreatedAt", "Description", "IsOverridable", "IsSystem", "Key", "OrgId", "Type", "UpdatedAt", "Value" },
                values: new object[,]
                {
                    { 1L, "Basic", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "系统名称", true, true, "SystemName", null, 0, null, "金兰®综合信息管理系统" },
                    { 2L, "Basic", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "系统Logo路径", true, true, "SystemLogo", null, 0, null, "/logo.svg" },
                    { 3L, "Basic", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "底部版权信息", true, true, "Copyright", null, 0, null, "©2025 Created by jinlan.info" },
                    { 4L, "Security", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "密码最小长度", true, true, "PasswordMinLength", null, 0, null, "6" },
                    { 5L, "Security", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "会话超时时间(分钟)", true, true, "SessionTimeout", null, 0, null, "30" }
                });

            migrationBuilder.InsertData(
                table: "sys_permission",
                columns: new[] { "Id", "Code", "Component", "CreatedAt", "Icon", "IsVisible", "Name", "ParentId", "Path", "Query", "SortOrder", "Type", "UpdatedAt" },
                values: new object[,]
                {
                    { 102L, "archive:fond:view", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "全宗查看", 47L, null, null, 1, "BUTTON", null },
                    { 103L, "archive:fond:add", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "全宗新增", 47L, null, null, 2, "BUTTON", null },
                    { 104L, "archive:fond:edit", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "全宗编辑", 47L, null, null, 3, "BUTTON", null },
                    { 105L, "archive:fond:delete", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "全宗删除", 47L, null, null, 4, "BUTTON", null },
                    { 106L, "archive:type:view", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "分类查看", 74L, null, null, 1, "BUTTON", null },
                    { 107L, "archive:type:add", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "分类新增", 74L, null, null, 2, "BUTTON", null },
                    { 108L, "archive:file:view", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "档案查看", 47L, null, null, 5, "BUTTON", null },
                    { 109L, "archive:file:add", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "档案新增", 47L, null, null, 6, "BUTTON", null },
                    { 110L, "archive:file:edit", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "档案编辑", 47L, null, null, 7, "BUTTON", null },
                    { 111L, "archive:file:delete", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "档案删除", 47L, null, null, 8, "BUTTON", null },
                    { 112L, "archive:type:edit", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "分类编辑", 74L, null, null, 3, "BUTTON", null },
                    { 113L, "archive:type:delete", null, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc), null, false, "分类删除", 74L, null, null, 4, "BUTTON", null }
                });

            migrationBuilder.InsertData(
                table: "sys_role",
                columns: new[] { "Id", "Code", "CreatedAt", "DeptId", "Description", "IsSystem", "Name", "UpdatedAt" },
                values: new object[] { 1L, "ADMIN", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, "系统最高权限", true, "超级管理员", null });

            migrationBuilder.InsertData(
                table: "sys_role_permission",
                columns: new[] { "PermissionId", "RoleId", "CreatedAt" },
                values: new object[,]
                {
                    { 102L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) },
                    { 103L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) },
                    { 104L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) },
                    { 105L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) },
                    { 106L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) },
                    { 107L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) },
                    { 108L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) },
                    { 109L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) },
                    { 110L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) },
                    { 111L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) },
                    { 112L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) },
                    { 113L, 1L, new DateTime(2025, 12, 22, 12, 0, 0, 0, DateTimeKind.Utc) }
                });

            migrationBuilder.InsertData(
                table: "sys_user",
                columns: new[] { "Id", "Avatar", "CreatedAt", "CurrentOrgId", "DeptId", "Email", "IsActive", "LastLoginAt", "Nickname", "Password", "Phone", "Status", "Username" },
                values: new object[] { 1L, null, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, true, null, "超级管理员", "240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9", null, "online", "admin" });

            migrationBuilder.InsertData(
                table: "sys_user_role",
                columns: new[] { "RoleId", "UserId", "CreatedAt" },
                values: new object[] { 1L, 1L, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) });

            migrationBuilder.CreateIndex(
                name: "IX_api_category_ParentId",
                table: "api_category",
                column: "ParentId");

            migrationBuilder.CreateIndex(
                name: "IX_api_definition_CategoryId",
                table: "api_definition",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_arch_attachment_ArchFileId",
                table: "arch_attachment",
                column: "ArchFileId");

            migrationBuilder.CreateIndex(
                name: "IX_arch_attachment_FileId",
                table: "arch_attachment",
                column: "FileId");

            migrationBuilder.CreateIndex(
                name: "IX_arch_box_BoxCode",
                table: "arch_box",
                column: "BoxCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_arch_box_FondId",
                table: "arch_box",
                column: "FondId");

            migrationBuilder.CreateIndex(
                name: "IX_arch_box_TypeId",
                table: "arch_box",
                column: "TypeId");

            migrationBuilder.CreateIndex(
                name: "IX_arch_file_ArchCode",
                table: "arch_file",
                column: "ArchCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_arch_file_BoxId",
                table: "arch_file",
                column: "BoxId");

            migrationBuilder.CreateIndex(
                name: "IX_arch_file_FondId",
                table: "arch_file",
                column: "FondId");

            migrationBuilder.CreateIndex(
                name: "IX_arch_file_TypeId",
                table: "arch_file",
                column: "TypeId");

            migrationBuilder.CreateIndex(
                name: "IX_arch_fond_Code",
                table: "arch_fond",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_arch_type_Code",
                table: "arch_type",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_arch_type_ParentId",
                table: "arch_type",
                column: "ParentId");

            migrationBuilder.CreateIndex(
                name: "IX_contract_attachment_contract_id",
                table: "contract_attachment",
                column: "contract_id");

            migrationBuilder.CreateIndex(
                name: "IX_contract_contact_contract_id",
                table: "contract_contact",
                column: "contract_id");

            migrationBuilder.CreateIndex(
                name: "IX_contract_invoice_contract_id",
                table: "contract_invoice",
                column: "contract_id");

            migrationBuilder.CreateIndex(
                name: "IX_contract_payment_plan_contract_id",
                table: "contract_payment_plan",
                column: "contract_id");

            migrationBuilder.CreateIndex(
                name: "IX_contract_payment_record_contract_id",
                table: "contract_payment_record",
                column: "contract_id");

            migrationBuilder.CreateIndex(
                name: "IX_frm_category_ParentId",
                table: "frm_category",
                column: "ParentId");

            migrationBuilder.CreateIndex(
                name: "IX_frm_definition_CategoryId",
                table: "frm_definition",
                column: "CategoryId");

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
                name: "IX_kb_qa_history_KbId",
                table: "kb_qa_history",
                column: "KbId");

            migrationBuilder.CreateIndex(
                name: "IX_page_categories_ParentId",
                table: "page_categories",
                column: "ParentId");

            migrationBuilder.CreateIndex(
                name: "IX_page_definitions_CategoryId",
                table: "page_definitions",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_sales_bid_chapter_analysis_id",
                table: "sales_bid_chapter",
                column: "analysis_id");

            migrationBuilder.CreateIndex(
                name: "IX_sales_bid_chapter_parent_id",
                table: "sales_bid_chapter",
                column: "parent_id");

            migrationBuilder.CreateIndex(
                name: "IX_sys_chat_conversation_ConversationKey",
                table: "sys_chat_conversation",
                column: "ConversationKey",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_sys_chat_conversation_RelatedId",
                table: "sys_chat_conversation",
                column: "RelatedId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_chat_conversation_User1Id",
                table: "sys_chat_conversation",
                column: "User1Id");

            migrationBuilder.CreateIndex(
                name: "IX_sys_chat_conversation_User2Id",
                table: "sys_chat_conversation",
                column: "User2Id");

            migrationBuilder.CreateIndex(
                name: "IX_sys_chat_message_ConversationKey",
                table: "sys_chat_message",
                column: "ConversationKey");

            migrationBuilder.CreateIndex(
                name: "IX_sys_config_Key_OrgId",
                table: "sys_config",
                columns: new[] { "Key", "OrgId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_sys_dept_ParentId",
                table: "sys_dept",
                column: "ParentId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_dict_category_parent_id",
                table: "sys_dict_category",
                column: "parent_id");

            migrationBuilder.CreateIndex(
                name: "IX_sys_dict_data_dict_type_id_value",
                table: "sys_dict_data",
                columns: new[] { "dict_type_id", "value" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_sys_dict_type_category_id",
                table: "sys_dict_type",
                column: "category_id");

            migrationBuilder.CreateIndex(
                name: "IX_sys_dict_type_code",
                table: "sys_dict_type",
                column: "code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_sys_file_DeptId",
                table: "sys_file",
                column: "DeptId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_file_OwnerId",
                table: "sys_file",
                column: "OwnerId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_file_ParentId",
                table: "sys_file",
                column: "ParentId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_file_share_FileId",
                table: "sys_file_share",
                column: "FileId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_file_share_SharedByUserId",
                table: "sys_file_share",
                column: "SharedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_file_share_SharedToUserId",
                table: "sys_file_share",
                column: "SharedToUserId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_permission_Code",
                table: "sys_permission",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_sys_post_Code",
                table: "sys_post",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_sys_post_DeptId",
                table: "sys_post",
                column: "DeptId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_role_Code",
                table: "sys_role",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_sys_role_DeptId",
                table: "sys_role",
                column: "DeptId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_role_inheritance_ChildRoleId",
                table: "sys_role_inheritance",
                column: "ChildRoleId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_user_DeptId",
                table: "sys_user",
                column: "DeptId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_user_Username",
                table: "sys_user",
                column: "Username",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_sys_user_post_DeptId",
                table: "sys_user_post",
                column: "DeptId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_user_post_PostId",
                table: "sys_user_post",
                column: "PostId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_user_role_RoleId",
                table: "sys_user_role",
                column: "RoleId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "api_definition");

            migrationBuilder.DropTable(
                name: "arch_attachment");

            migrationBuilder.DropTable(
                name: "bigview_project");

            migrationBuilder.DropTable(
                name: "contract_attachment");

            migrationBuilder.DropTable(
                name: "contract_contact");

            migrationBuilder.DropTable(
                name: "contract_invoice");

            migrationBuilder.DropTable(
                name: "contract_knowledge_category");

            migrationBuilder.DropTable(
                name: "contract_knowledge_file");

            migrationBuilder.DropTable(
                name: "contract_payment_plan");

            migrationBuilder.DropTable(
                name: "contract_payment_record");

            migrationBuilder.DropTable(
                name: "contract_stat");

            migrationBuilder.DropTable(
                name: "contract_template");

            migrationBuilder.DropTable(
                name: "data_source_connection");

            migrationBuilder.DropTable(
                name: "frm_data");

            migrationBuilder.DropTable(
                name: "frm_definition");

            migrationBuilder.DropTable(
                name: "kb_node_source");

            migrationBuilder.DropTable(
                name: "kb_qa_history");

            migrationBuilder.DropTable(
                name: "page_definitions");

            migrationBuilder.DropTable(
                name: "project_attachments");

            migrationBuilder.DropTable(
                name: "project_info");

            migrationBuilder.DropTable(
                name: "project_phases");

            migrationBuilder.DropTable(
                name: "project_swimlanes");

            migrationBuilder.DropTable(
                name: "project_task_dependencies");

            migrationBuilder.DropTable(
                name: "project_tasks");

            migrationBuilder.DropTable(
                name: "sales_bid_analysis_log");

            migrationBuilder.DropTable(
                name: "sales_bid_analysis_run");

            migrationBuilder.DropTable(
                name: "sales_bid_chapter");

            migrationBuilder.DropTable(
                name: "sales_bid_project");

            migrationBuilder.DropTable(
                name: "sales_customer");

            migrationBuilder.DropTable(
                name: "sales_opportunity");

            migrationBuilder.DropTable(
                name: "sales_process_rule");

            migrationBuilder.DropTable(
                name: "sales_product_doc");

            migrationBuilder.DropTable(
                name: "sales_registrations");

            migrationBuilder.DropTable(
                name: "sales_script");

            migrationBuilder.DropTable(
                name: "sales_target");

            migrationBuilder.DropTable(
                name: "sys_audit_log");

            migrationBuilder.DropTable(
                name: "sys_chat_conversation");

            migrationBuilder.DropTable(
                name: "sys_chat_message");

            migrationBuilder.DropTable(
                name: "sys_config");

            migrationBuilder.DropTable(
                name: "sys_dict_data");

            migrationBuilder.DropTable(
                name: "sys_file_share");

            migrationBuilder.DropTable(
                name: "sys_org_registration");

            migrationBuilder.DropTable(
                name: "sys_permission");

            migrationBuilder.DropTable(
                name: "sys_role_inheritance");

            migrationBuilder.DropTable(
                name: "sys_role_permission");

            migrationBuilder.DropTable(
                name: "sys_user_post");

            migrationBuilder.DropTable(
                name: "sys_user_role");

            migrationBuilder.DropTable(
                name: "api_category");

            migrationBuilder.DropTable(
                name: "arch_file");

            migrationBuilder.DropTable(
                name: "contract_main");

            migrationBuilder.DropTable(
                name: "frm_category");

            migrationBuilder.DropTable(
                name: "kb_file");

            migrationBuilder.DropTable(
                name: "page_categories");

            migrationBuilder.DropTable(
                name: "sales_bid_analysis");

            migrationBuilder.DropTable(
                name: "sys_dict_type");

            migrationBuilder.DropTable(
                name: "sys_file");

            migrationBuilder.DropTable(
                name: "sys_post");

            migrationBuilder.DropTable(
                name: "sys_role");

            migrationBuilder.DropTable(
                name: "arch_box");

            migrationBuilder.DropTable(
                name: "kb_info");

            migrationBuilder.DropTable(
                name: "sys_dict_category");

            migrationBuilder.DropTable(
                name: "sys_user");

            migrationBuilder.DropTable(
                name: "arch_fond");

            migrationBuilder.DropTable(
                name: "arch_type");

            migrationBuilder.DropTable(
                name: "sys_dept");
        }
    }
}
