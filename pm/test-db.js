
const fetch = require('node-fetch'); // You might need to install this or use built-in fetch in newer node
// Using built-in fetch if node 18+

async function test() {
    const baseUrl = 'http://localhost:3000';
    
    // 1. Login
    console.log('Testing Login...');
    const loginRes = await fetch(`${baseUrl}/api/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username: 'admin', password: 'password' })
    });
    const loginData = await loginRes.json();
    console.log('Login:', loginData);

    if (!loginData.success) {
        console.error('Login failed');
        return;
    }

    // 2. Save Project
    console.log('Testing Save Project...');
    const projectData = {
        projectInfo: {
            code: 'PRJ-TEST-DB',
            name: 'Test Project DB',
            type: 'Test',
            description: 'Testing DB Integration',
            manager: 'Tester',
            plannedStartDate: '2024-01-01',
            plannedEndDate: '2024-12-31'
        },
        phases: [{ id: 'p1', name: 'Phase 1', color: '#ffffff' }],
        swimlanes: [{ id: 's1', name: 'Swimlane 1', color: '#eeeeee' }],
        tasks: [
            {
                id: 't1',
                name: 'Task 1',
                phaseId: 'p1',
                swimlaneId: 's1',
                status: 'pending',
                progress: 0,
                owner: 'Tester',
                startDate: '2024-01-02',
                endDate: '2024-01-05',
                type: 'task',
                dependencies: [],
                attachments: []
            }
        ]
    };

    const saveRes = await fetch(`${baseUrl}/api/project/PRJ-TEST-DB`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(projectData)
    });
    const saveData = await saveRes.json();
    console.log('Save:', saveData);

    // 3. Get Project
    console.log('Testing Get Project...');
    const getRes = await fetch(`${baseUrl}/api/project/PRJ-TEST-DB`);
    const getData = await getRes.json();
    console.log('Get Project Info Name:', getData.projectInfo.name);
    console.log('Get Project Tasks:', getData.tasks.length);
}

test().catch(console.error);
