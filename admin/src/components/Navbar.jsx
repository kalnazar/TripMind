import React, { useContext } from "react";
import { assets } from "../assets/assets";
import { AdminContext } from "../context/AdminContext";
import { useNavigate } from "react-router-dom";
import { ExpertContext } from "../context/ExpertContext";

const Navbar = () => {
  const { aToken, setAToken } = useContext(AdminContext);
  const { eToken, setEToken } = useContext(ExpertContext);

  const navigate = useNavigate();

  const logout = () => {
    navigate("/");
    aToken && setAToken("");
    aToken && localStorage.removeItem("aToken");
    eToken && setEToken("");
    eToken && localStorage.removeItem("eToken");
  };

  return (
    <div className="sticky top-0 z-20 flex justify-between items-center px-4 sm:px-10 py-3 border-b border-slate-200/80 bg-white/70 backdrop-blur">
      <div className="flex items-center gap-2 text-xs">
        <img
          className="w-10 h-10 cursor-pointer"
          src={assets.admin_logo}
          alt="TripMind logo"
        />
        <span className="text-base sm:text-lg font-semibold text-gray-800">
          Trip<span className="text-primary">Mind</span>
        </span>
        <span className="tm-chip">{aToken ? "Admin" : "Expert"}</span>
      </div>
      <button
        onClick={logout}
        className="tm-button rounded-full px-6 text-sm"
      >
        Logout
      </button>
    </div>
  );
};

export default Navbar;
