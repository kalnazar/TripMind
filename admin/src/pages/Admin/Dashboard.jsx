import React, { useContext, useEffect } from "react";
import { AdminContext } from "../../context/AdminContext";
import { assets } from "../../assets/assets";

const Dashboard = () => {
  const { aToken, dashData, getDashboard, users, listUsers } =
    useContext(AdminContext);

  useEffect(() => {
    if (aToken) {
      getDashboard();
      listUsers();
    }
  }, [aToken]);

  const visibleUsers = users.filter(
    (user) => String(user.role || "USER").toUpperCase() !== "ADMIN"
  );

  return (
    dashData && (
      <div className="m-5">
        <div className="flex flex-wrap gap-3">
          <div className="tm-card flex items-center gap-2 p-4 min-w-52 cursor-pointer hover:-translate-y-0.5 transition-all">
            <img className="w-14" src={assets.clients_icon} alt="" />
            <div>
              <p className="text-xl font-semibold text-gray-600">
                {dashData.users}
              </p>
              <p className="text-gray-400">Users</p>
            </div>
          </div>
          <div className="tm-card flex items-center gap-2 p-4 min-w-52 cursor-pointer hover:-translate-y-0.5 transition-all">
            <img className="w-14" src={assets.people_icon} alt="" />
            <div>
              <p className="text-xl font-semibold text-gray-600">
                {dashData.experts}
              </p>
              <p className="text-gray-400">Experts</p>
            </div>
          </div>
          <div className="tm-card flex items-center gap-2 p-4 min-w-52 cursor-pointer hover:-translate-y-0.5 transition-all">
            <img className="w-14" src={assets.booking_icon} alt="" />
            <div>
              <p className="text-xl font-semibold text-gray-600">
                {dashData.trips}
              </p>
              <p className="text-gray-400">Trips</p>
            </div>
          </div>
          <div className="tm-card flex items-center gap-2 p-4 min-w-52 cursor-pointer hover:-translate-y-0.5 transition-all">
            <img className="w-14" src={assets.list_icon} alt="" />
            <div>
              <p className="text-xl font-semibold text-gray-600">
                {dashData.itineraries}
              </p>
              <p className="text-gray-400">Itineraries</p>
            </div>
          </div>
        </div>

        <div className="tm-card mt-10 overflow-hidden">
          <div className="flex items-center gap-2.5 px-4 py-4 border-b border-gray-200">
            <img src={assets.list_icon} alt="" />
            <p className="font-semibold">Users</p>
          </div>

          {visibleUsers.length === 0 ? (
            <div className="px-6 py-6 text-sm text-gray-500">
              No users found yet.
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full text-sm">
                <thead className="bg-gray-50 text-gray-500">
                  <tr>
                    <th className="text-left px-6 py-3 font-medium">Name</th>
                    <th className="text-left px-6 py-3 font-medium">Email</th>
                    <th className="text-left px-6 py-3 font-medium">Role</th>
                    <th className="text-left px-6 py-3 font-medium">
                      Itineraries
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {visibleUsers.map((user) => {
                    const role = String(user.role || "USER").toUpperCase();
                    const roleClass =
                      role === "EXPERT"
                        ? "bg-green-100 text-green-700"
                        : "bg-primary/10 text-primary";
                    return (
                      <tr
                        key={user.id}
                        className="border-t border-gray-100 text-gray-700"
                      >
                        <td className="px-6 py-3 font-medium text-gray-900">
                          {user.name}
                        </td>
                        <td className="px-6 py-3">{user.email}</td>
                        <td className="px-6 py-3">
                          <span
                            className={`px-2 py-1 rounded-full text-xs font-semibold ${roleClass}`}
                          >
                            {role}
                          </span>
                        </td>
                        <td className="px-6 py-3">
                          {user.itineraryCount ?? 0}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    )
  );
};

export default Dashboard;
