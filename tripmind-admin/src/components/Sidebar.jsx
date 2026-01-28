import React, { useContext } from "react";
import { AdminContext } from "../context/AdminContext";
import { NavLink } from "react-router-dom";
import { assets } from "../assets/assets";
import { ExpertContext } from "../context/ExpertContext";

const Sidebar = () => {
  const { aToken } = useContext(AdminContext);
  const { eToken } = useContext(ExpertContext);

  return (
    <div className="min-h-screen bg-white/70 backdrop-blur border-r border-slate-200/80">
      {aToken && (
        <ul className="text-[#515151] mt-5">
          <NavLink
            className={({ isActive }) =>
              `flex items-center gap-3 py-3.5 px-3 md:px-9 md:min-w-72 cursor-pointer transition ${
                isActive
                  ? "bg-primary/10 border-r-4 border-primary text-primary"
                  : "hover:bg-primary/5"
              }`
            }
            to={"/admin-dashboard"}
          >
            <img src={assets.home_icon} alt="" />
            <p className="hidden md:block">Dashboard</p>
          </NavLink>
          <NavLink
            className={({ isActive }) =>
              `flex items-center gap-3 py-3.5 px-3 md:px-9 md:min-w-72 cursor-pointer transition ${
                isActive
                  ? "bg-primary/10 border-r-4 border-primary text-primary"
                  : "hover:bg-primary/5"
              }`
            }
            to={"/experts"}
            end
          >
            <img src={assets.people_icon} alt="" />
            <p className="hidden md:block">Experts</p>
          </NavLink>
          <NavLink
            className={({ isActive }) =>
              `flex items-center gap-3 py-3.5 px-3 md:px-9 md:min-w-72 cursor-pointer transition ${
                isActive
                  ? "bg-primary/10 border-r-4 border-primary text-primary"
                  : "hover:bg-primary/5"
              }`
            }
            to={"/experts/add"}
          >
            <img src={assets.add_icon} alt="" />
            <p className="hidden md:block">Add Expert</p>
          </NavLink>
        </ul>
      )}
      {eToken && (
        <ul className="text-[#515151] mt-5">
          <NavLink
            className={({ isActive }) =>
              `flex items-center gap-3 py-3.5 px-3 md:px-9 md:min-w-72 cursor-pointer transition ${
                isActive
                  ? "bg-primary/10 border-r-4 border-primary text-primary"
                  : "hover:bg-primary/5"
              }`
            }
            to={"/expert-profile"}
          >
            <img src={assets.home_icon} alt="" />
            <p className="hidden md:block">My Profile</p>
          </NavLink>
          <NavLink
            className={({ isActive }) =>
              `flex items-center gap-3 py-3.5 px-3 md:px-9 md:min-w-72 cursor-pointer transition ${
                isActive
                  ? "bg-primary/10 border-r-4 border-primary text-primary"
                  : "hover:bg-primary/5"
              }`
            }
            to={"/expert-bookings"}
          >
            <img src={assets.list_icon} alt="" />
            <p className="hidden md:block">Bookings</p>
          </NavLink>
        </ul>
      )}
    </div>
  );
};

export default Sidebar;
