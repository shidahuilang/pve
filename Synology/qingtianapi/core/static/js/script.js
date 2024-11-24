document.addEventListener('DOMContentLoaded', function() {
    let usersData = [];

    // 显示用户信息的函数
function displayUsers(users) {
    const userList = document.getElementById('userList');
    userList.innerHTML = '';  // 清空现有列表
    users.forEach(user => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${user.email}</td>
            <td>${user.registration_time}</td>
            <td>${user.last_read_date}</td>
            <td>${user.read_count}</td>
            <td>${user.day_read_count}</td>
            <td>${user.ban_count}</td>
            <td>
                <button class="btn ${user.is_banned ? 'btn-danger' : 'btn-success'} btn-sm" onclick="toggleBan('${user.email}>>>${user.key}')">
                ${user.is_banned ? '解封' : '封禁'}
                </button>
            </td>
            <td>${user.unban_time}</td>
            <td>
                <button class="btn ${user.vip ? 'btn-success' : 'btn-danger'} btn-sm" onclick="vip('${user.email}>>>${user.key}')">
                ${user.vip ? '是' : '否'}
                </button>
            </td>
            <td>${user.key}</td>
            <td><button class="btn btn-danger btn-sm" onclick="deleteUser('${user.email}>>>${user.key}')">删除</button></td>
        `;
        userList.appendChild(row);
    });
}

// 排序函数
function sortUsers(criteria) {
    if (criteria === 'read_count') {
        usersData.sort((a, b) => b.read_count - a.read_count);
    } else if (criteria === 'day_read_count') {
        usersData.sort((a, b) => b.day_read_count - a.day_read_count);
    } else if (criteria === 'ban_count') {
        usersData.sort((a, b) => b.ban_count - a.ban_count);
    } else if (criteria === 'registration_time') {
        usersData.sort((a, b) => new Date(b.registration_time) - new Date(a.registration_time));
    } else if (criteria === 'last_read_date') {
        usersData.sort((a, b) => {
            const lastReadA = a.last_read_date === '' || a.last_read_date === '未开始' ? 0 : new Date(a.last_read_date);
            const lastReadB = b.last_read_date === '' || b.last_read_date === '未开始' ? 0 : new Date(b.last_read_date);
            return lastReadB - lastReadA; // 降序排序
        });
    } else if (criteria === 'unban_time') {
        usersData.sort((a, b) => {
            const unbanA = a.unban_time === '正常' ? 0 : (a.unban_time === '永久封禁' ? 4070880000000 : new Date(a.unban_time));
            const unbanB = b.unban_time === '正常' ? 0 : (b.unban_time === '永久封禁' ? 4070880000000 : new Date(b.unban_time));
            return unbanB - unbanA; // 降序排序
        });
    } else if (criteria === 'is_banned') {
        usersData.sort((a, b) => b.is_banned - a.is_banned);
    } else if (criteria === 'vip') {
        usersData.sort((a, b) => b.vip - a.vip);
    }
    displayUsers(usersData);  // 排序后重新渲染用户列表
}

// 点击排序按钮
document.getElementById('sortReadCount').addEventListener('click', function() {
    sortUsers('read_count');
});
document.getElementById('daySortReadCount').addEventListener('click', function() {
    sortUsers('day_read_count');
});
document.getElementById('sortBanCount').addEventListener('click', function() {
    sortUsers('ban_count');
});
document.getElementById('sortRegistrationTime').addEventListener('click', function() {
    sortUsers('registration_time');
});
document.getElementById('sortLastReadTime').addEventListener('click', function() {
    sortUsers('last_read_date');
});
document.getElementById('sortUnbanTime').addEventListener('click', function() {
    sortUsers('unban_time');
});
document.getElementById('sortBanStatus').addEventListener('click', function() {
    sortUsers('is_banned');
});
document.getElementById('vip').addEventListener('click', function() {
    sortUsers('vip');
});

    // 搜索功能
    document.getElementById('searchButton').addEventListener('click', function() {
        const query = document.getElementById('searchInput').value;
        fetch(`/api/search_user?query=${query}`)
            .then(response => response.json())
            .then(data => {
                usersData = data;
                displayUsers(usersData);
            });
    });

    // 设置模块
    document.getElementById('settingsForm').addEventListener('submit', function(e) {
        e.preventDefault(); // 防止表单提交刷新页面
        const max_requests = document.getElementById('max_requests').value;
        const online_max_requests = document.getElementById('online_max_requests').value;
        const time_frame = document.getElementById('time_frame').value;
        const ban_duration = document.getElementById('ban_duration').value;
        const advertisement = document.getElementById('advertisement').value;
        const notification = document.getElementById('notification').value;
        const ximalayacookie = document.getElementById('ximalayacookie').value;

        fetch('/api/update_settings', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                max_requests,
                online_max_requests,
                time_frame,
                ban_duration,
                advertisement,
                notification,
                ximalayacookie
            })
        })
        .then(response => response.json())
        .then(data => {
            alert(data.status === 'success' ? '修改成功' : '修改失败');
        });
    });

    // 获取并展示用户数据
    fetch('/api/users')
        .then(response => response.json())
        .then(data => {
            usersData = data;
            displayUsers(usersData);
        });
});

// 封禁/解封用户的函数
function toggleBan(userId) {
    fetch(`/api/toggle_ban/${userId}`, {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            alert(data.is_banned ? '用户已被封禁' : '用户已解封');
            // 刷新用户列表
            location.reload();
        } else {
            alert(data.message || '操作失败');
        }
    });
}
// 切换会员用户的函数
function vip(userId) {
    fetch(`/api/vip/${userId}`, {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            alert(data.vip ? '成功设置为会员' : '已取消会员');
            // 刷新用户列表
            location.reload();
        } else {
            alert(data.message || '操作失败');
        }
    });
}
// 删除用户的函数
function deleteUser(userId) {
    if (confirm('确定要删除此用户吗？')) {
        fetch(`/api/delete_user/${userId}`, {
            method: 'DELETE'
        })
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                alert('用户已删除');
                // 刷新用户列表
                location.reload();
            } else {
                alert(data.message || '操作失败');
            }
        });
    }
}

function uploadFiles() {
            const formData = new FormData();

            // 获取每个文件输入框的文件
            const androidFile = document.getElementById('androidSource').files[0];
            const pureReadFile = document.getElementById('pureReadSource').files[0];
            const minimalFile = document.getElementById('minimalSource').files[0];
            const xiangseFile = document.getElementById('xiangseSource').files[0];

            // 检查文件是否已选
            if (androidFile) formData.append('androidSource', androidFile);
            if (pureReadFile) formData.append('pureReadSource', pureReadFile);
            if (minimalFile) formData.append('minimalSource', minimalFile);
            if (xiangseFile) formData.append('xiangseSource', xiangseFile);

            // 发送文件到服务器
            fetch('/upload', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                alert('上传结果:\n ' + data.message);
            })
            .catch(error => {
                console.error('上传失败:\n ', error);
            });
        }