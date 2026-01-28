import React, { useContext, useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { AdminContext } from "../../context/AdminContext";

const ExpertsList = () => {
  const { aToken, experts, listExperts, updateExpert, deleteExpert } =
    useContext(AdminContext);
  const [selectedExpert, setSelectedExpert] = useState(null);

  useEffect(() => {
    if (aToken) {
      listExperts();
    }
  }, [aToken]);

  return (
    <div className="m-5 w-full">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-lg font-medium">Experts</h1>
          <p className="text-sm text-gray-500">
            Manage expert accounts available in TripMind.
          </p>
        </div>
        <Link
          to="/experts/add"
          className="tm-button rounded-full px-5 text-sm"
        >
          Add Expert
        </Link>
      </div>

      {experts.length === 0 ? (
        <div className="mt-8 tm-card p-6 text-sm text-gray-600">
          No experts found yet. Add your first expert to get started.
        </div>
      ) : (
        <div className="mt-6 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {experts.map((expert) => {
            const initials = expert?.name
              ? expert.name
                  .split(" ")
                  .map((part) => part[0])
                  .slice(0, 2)
                  .join("")
                  .toUpperCase()
              : "EX";

            return (
              <div
                key={expert.id}
                role="button"
                tabIndex={0}
                onClick={() => setSelectedExpert(expert)}
                onKeyDown={(e) => {
                  if (e.key === "Enter" || e.key === " ") {
                    setSelectedExpert(expert);
                  }
                }}
                className="tm-card p-5 flex flex-col gap-4 h-full cursor-pointer hover:shadow-lg transition-shadow"
              >
                <div className="flex items-center gap-4">
                  {expert.avatarUrl ? (
                    <img
                      src={expert.avatarUrl}
                      alt={expert.name}
                      className="w-12 h-12 rounded-full object-cover"
                    />
                  ) : (
                    <div className="w-12 h-12 rounded-full bg-primary/10 text-primary flex items-center justify-center text-sm font-semibold">
                      {initials}
                    </div>
                  )}
                  <div className="min-w-0">
                    <p className="text-gray-900 font-medium truncate">
                      {expert.name}
                    </p>
                    <p className="text-gray-500 text-sm truncate">
                      {expert.email}
                    </p>
                    {expert.location && (
                      <p className="text-gray-400 text-xs truncate">
                        {expert.location}
                      </p>
                    )}
                  </div>
                </div>

                <div className="text-sm text-gray-600 space-y-1 flex-1">
                  {expert.languages && (
                    <p>
                      <span className="text-gray-500">Languages:</span>{" "}
                      {expert.languages}
                    </p>
                  )}
                  {expert.countryCode && (
                    <p>
                      <span className="text-gray-500">Country:</span>{" "}
                      {expert.countryCode}
                    </p>
                  )}
                  {expert.timeZone && (
                    <p>
                      <span className="text-gray-500">Time zone:</span>{" "}
                      {expert.timeZone}
                    </p>
                  )}
                  {expert.experienceYears != null && (
                    <p>
                      <span className="text-gray-500">Experience:</span>{" "}
                      {expert.experienceYears} yrs
                    </p>
                  )}
                  {expert.pricePerHour != null && (
                    <p>
                      <span className="text-gray-500">Price:</span> ${" "}
                      {expert.pricePerHour}/hour
                    </p>
                  )}
                  {expert.bio && (
                    <p className="text-gray-500 line-clamp-2">{expert.bio}</p>
                  )}
                </div>

                <div className="mt-auto flex items-center justify-between gap-3">
                  <label
                    className="flex items-center gap-2 text-sm text-gray-600"
                    onClick={(e) => e.stopPropagation()}
                  >
                    <input
                      type="checkbox"
                      checked={Boolean(expert.isShown)}
                      onChange={(e) => {
                        updateExpert(expert.id, {
                          isShown: e.target.checked,
                        }).catch(() => {});
                      }}
                      className="cursor-pointer"
                    />
                    Show on TripMind
                  </label>
                  <button
                    className="text-xs font-semibold text-red-600 hover:text-red-700"
                    onClick={(e) => {
                      e.stopPropagation();
                      if (
                        window.confirm(
                          `Delete ${expert.name}? This cannot be undone.`
                        )
                      ) {
                        deleteExpert(expert.id).catch(() => {});
                      }
                    }}
                  >
                    Delete
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {selectedExpert && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
          onClick={() => setSelectedExpert(null)}
        >
          <div
            className="tm-card w-full max-w-xl p-6"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                {selectedExpert.avatarUrl ? (
                  <img
                    src={selectedExpert.avatarUrl}
                    alt={selectedExpert.name}
                    className="w-14 h-14 rounded-full object-cover"
                  />
                ) : (
                  <div className="w-14 h-14 rounded-full bg-primary/10 text-primary flex items-center justify-center text-base font-semibold">
                    {(selectedExpert.name || "EX")
                      .split(" ")
                      .map((part) => part[0])
                      .slice(0, 2)
                      .join("")
                      .toUpperCase()}
                  </div>
                )}
                <div>
                  <p className="text-lg font-semibold text-gray-900">
                    {selectedExpert.name}
                  </p>
                  <p className="text-sm text-gray-500">
                    {selectedExpert.email}
                  </p>
                </div>
              </div>
              <button
                className="text-sm text-gray-500 hover:text-gray-700"
                onClick={() => setSelectedExpert(null)}
              >
                Close
              </button>
            </div>

            <div className="mt-5 space-y-2 text-sm text-gray-700">
              {selectedExpert.location && (
                <p>
                  <span className="text-gray-500">Location:</span>{" "}
                  {selectedExpert.location}
                </p>
              )}
              {selectedExpert.languages && (
                <p>
                  <span className="text-gray-500">Languages:</span>{" "}
                  {selectedExpert.languages}
                </p>
              )}
              {selectedExpert.countryCode && (
                <p>
                  <span className="text-gray-500">Country:</span>{" "}
                  {selectedExpert.countryCode}
                </p>
              )}
              {selectedExpert.timeZone && (
                <p>
                  <span className="text-gray-500">Time zone:</span>{" "}
                  {selectedExpert.timeZone}
                </p>
              )}
              {selectedExpert.experienceYears != null && (
                <p>
                  <span className="text-gray-500">Experience:</span>{" "}
                  {selectedExpert.experienceYears} yrs
                </p>
              )}
              {selectedExpert.pricePerHour != null && (
                <p>
                  <span className="text-gray-500">Price:</span>{" "}
                  ${selectedExpert.pricePerHour}/hour
                </p>
              )}
              {selectedExpert.bio && (
                <p className="text-gray-500">{selectedExpert.bio}</p>
              )}
              <p>
                <span className="text-gray-500">Visible:</span>{" "}
                {selectedExpert.isShown ? "Yes" : "No"}
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ExpertsList;
