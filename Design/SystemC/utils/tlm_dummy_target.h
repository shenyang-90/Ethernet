#ifndef TLM_DUMMY_TARGET_H
#define TLM_DUMMY_TARGET_H

/**
 * @file tlm_dummy_target.h
 * @brief Dummy Target for Unbound TLM Sockets (PAD 骨架)
 */

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>

namespace ethernet_tlm {

/**
 * @class tlm_dummy_target
 * @brief 虚拟 Target，用于绑定未连接的 initiator socket，避免仿真报错
 */
class tlm_dummy_target : public sc_core::sc_module {
public:
    tlm_utils::simple_target_socket<tlm_dummy_target> socket;

    SC_CTOR(tlm_dummy_target)
        : socket("socket")
    {
        socket.register_b_transport(this, &tlm_dummy_target::b_transport);
        socket.register_nb_transport_fw(this, &tlm_dummy_target::nb_transport_fw);
        socket.register_get_direct_mem_ptr(this, &tlm_dummy_target::get_direct_mem_ptr);
        socket.register_transport_dbg(this, &tlm_dummy_target::transport_dbg);
    }

    void b_transport(tlm::tlm_generic_payload& trans,
                     sc_core::sc_time& delay)
    {
        wait(delay);
        delay = sc_core::SC_ZERO_TIME;
    }

    tlm::tlm_sync_enum nb_transport_fw(tlm::tlm_generic_payload& trans,
                                        tlm::tlm_phase& phase,
                                        sc_core::sc_time& delay)
    {
        return tlm::TLM_ACCEPTED;
    }

    bool get_direct_mem_ptr(tlm::tlm_generic_payload& trans,
                            tlm::tlm_dmi& dmi_data)
    {
        return false;
    }

    unsigned int transport_dbg(tlm::tlm_generic_payload& trans)
    {
        return 0;
    }
};

} // namespace ethernet_tlm

#endif // TLM_DUMMY_TARGET_H
